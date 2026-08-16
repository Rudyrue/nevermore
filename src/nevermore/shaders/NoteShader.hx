package nevermore.shaders;

import flixel.graphics.tile.FlxGraphicsShader;

/**
 * A custom coloring method, mainly for quants.
 * 
 * Grayscales then turns Black-Gray-White to Black-(INPUT-COLOR)-White.
 */
class NoteShader extends FlxGraphicsShader {
    @:glVertexSource("#pragma header

    attribute vec2 verts;
    attribute vec4 stealthColor;

    varying vec4 stealthCol;

    attribute float alpha;
    attribute vec4 colorMultiplier;
    attribute vec4 colorOffset;

    const float offsetDiv = 1.0 / 255.0;

    void main() {
		openfl_TextureCoordv = openfl_TextureCoord;
		gl_Position = openfl_Matrix * vec4(verts, 0.0, 1.0);

        openfl_Alphav = openfl_Alpha * alpha * min(2.0 - stealthColor.a * 2.0, 1.0);
        
        openfl_ColorOffsetv = colorOffset * offsetDiv;
        openfl_ColorMultiplierv = colorMultiplier;

        stealthCol = stealthColor;
        stealthCol.a = min(stealthCol.a * 2.0, 1.0);
    }")
	@:glFragmentSource("#pragma header
    
    varying vec4 stealthCol;
    uniform bool canColor;

    void main() {
        // no need for flixel_, we're using .color differently
        vec4 col = texture2D(bitmap, openfl_TextureCoordv);
        if (col.a <= 0.0)
            discard;
        col.rgb /= col.a;

        if (canColor) {
            // float gray = (col.r + col.g + col.b) * thirds; Old Method. (Channel Average, thirds = 2.0 / 3.0)

            // https://css-tricks.com/using-javascript-to-adjust-saturation-and-brightness-of-rgb-colors/#:~:text=JavaScript%20function%20for%20this%3A
            float high = max(max(col.r, col.g), col.b);
            float low = min(min(col.r, col.g), col.b);

            float gray = high + low;
            if (gray > 1.0)
                gl_FragColor = vec4(mix(openfl_ColorMultiplierv.rgb, vec3(1.0), gray - 1.0), col.a);
            else
                gl_FragColor = vec4(openfl_ColorMultiplierv.rgb * gray, col.a);
        } else {
            gl_FragColor = clamp(openfl_ColorOffsetv + (col * openfl_ColorMultiplierv), 0.0, 1.0);
        }
        gl_FragColor.rgb = mix(gl_FragColor.rgb, stealthCol.rgb, stealthCol.a);
        gl_FragColor.rgb *= col.a;
        gl_FragColor *= openfl_Alphav;
    }")

    // just in case
    public function new() {
        super();
    }
}