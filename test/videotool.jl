"""
Takes `frames`, which is supposed to be an array of images,
saves them as png's at path and then creates an webm video
from that with the name `name`
"""
function create_video(frames::Vector, name, screencap_folder)
    println("saving frames for $name")
    mktempdir() do path
        for (i,frame) in enumerate(frames)
            save(joinpath(path, "$name$i.png"), frame, true)
        end
        len = length(frames)
        frames = [] # free frames...
        oldpath = pwd()
        cd(path)
        mktemp(path) do io, path
            # output stdout to tmpfile , since there is too much going on with it
            run(pipeline(
                `png2yuv -I p -f 30 -b 1 -n $len -j $name%d.png`,
                stdout="$(name).yuv", stdin=io, stderr=io
            ))
            run(pipeline(
                `vpxenc --good --cpu-used=0 --auto-alt-ref=1 --lag-in-frames=16 --end-usage=vbr --passes=1 --threads=4 --target-bitrate=3500 -o $(name).webm $(name).yuv`,
                stdout=io, stdin=io, stderr=io
            ))
        end
        targetpath = abspath(joinpath(screencap_folder, "$(name).webm"))
        sourcepath = abspath("$(name).webm")
        mv(sourcepath, targetpath)
        cd(oldpath)
    end
end

function create_video(frame, name, path)
    println("saving static image for $name")
    targetpath = abspath(joinpath(path, "$(name).png"))
    save(targetpath, frame, true)
end
#downsample
#`ffmpeg -i volume.webm -codec:v libvpx -quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -threads 4 -vf scale=-1:480 -codec:a libvorbis -b:a 128k volume2.webm`