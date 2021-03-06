function button(a, window)
    robj = visualize(a).children[]
    const m2id = mouse2id(window)
    is_pressed = droprepeats(map(window.inputs[:key_pressed]) do isclicked
        isclicked && value(m2id).id == robj.id
    end)

    robj[:model] = const_lift(is_pressed, robj[:model], boundingbox(robj)) do ip, old, bb
        ip && return old
        scalematrix(Vec3f0(0.95))*old
    end
    robj, is_pressed
end


function toggle_button(a::Signal, b::Composable, window)
    toggle(b, window, signal=a)
    b, a
end

function toggle_button(a, b, window)
    id = Signal(0)
    ab_bool = toggle(id, window)
    a_b = map(ab_bool) do aORb
        aORb ? a : b
    end
    robj = visualize(a_b)
    push!(id, robj.children[].id)
    robj, ab_bool
end

function toggle(ispressed::Signal{Bool}, window, default=true; signal=Signal(default))
    preserve(map(ispressed) do ispressed
        ispressed && push!(signal, !Bool(value(signal)))
        nothing
    end)
    signal
end

function toggle{T<:Union{Int, Tuple, RenderObject}}(id1::Union{Signal{T}, T}, window, default=true; signal=Signal(default))
    is_clicked = droprepeats(map(window.inputs[:mouse_buttons_pressed]) do mbp
        if GLAbstraction.singlepressed(mbp, GLFW.MOUSE_BUTTON_LEFT)
            id2 = value(mouse2id(window))
            return is_same_id(id2, value(id1))
        end
        false
    end)
    toggle(is_clicked, window, default; signal=signal)
end

function toggle(robj::RenderObject, window, default=true; signal=Signal(default))
    toggle(robj, window, default, signal=signal)
end

function toggle(c::Context, window, default=true; signal=Signal(default))
    toggle(map(x->x.id, tuple(GLAbstraction.extract_renderable(c)...)), window, default, signal=signal)
end
