shader_type canvas_item;

uniform bool enable_effect = false;

void fragment() {
    COLOR = texture(TEXTURE, UV); // Read from texture again.

    if (enable_effect){
        COLOR.r = 1.0; //set red channel to 1.0
    }
	
	

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
