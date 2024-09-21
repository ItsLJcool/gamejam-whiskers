shader_type canvas_item;

uniform vec4 tile_color = vec4(1,1,1,1);

void fragment() {
    COLOR = texture(TEXTURE, UV) * tile_color;
}
