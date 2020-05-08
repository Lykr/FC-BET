function angle = vector_to_angle(vec)
    angle = atan2(vec(2), vec(1));
    
    if angle < 0
        angle = 2 * pi + angle;
    end
end
