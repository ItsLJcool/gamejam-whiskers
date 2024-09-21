shader_type canvas_item;

uniform vec3 r:source_color = vec3(1.0,0.0,0.0);
uniform vec3 g:source_color = vec3(1.0,1.0,1.0);
uniform vec3 b:source_color = vec3(1.0,1.0,1.0);

void fragment() {   
    COLOR.rgb = COLOR.r * r + COLOR.g * g + COLOR.b * b;
}