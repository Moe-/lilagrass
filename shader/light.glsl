vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
	vec4 lightBuffer = Texel(texture, texture_coords);

	if(lightBuffer.a == 0.0) {
		return vec4(1);
	} else {
		return lightBuffer;
	}
}