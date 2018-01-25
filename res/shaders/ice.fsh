#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

uniform int flag; //控制和恢复

void main()
{
	if (flag > 0)
	{
		vec4 c = texture2D(u_texture, v_texCoord) * v_fragmentColor;
		float brightness = (c.r + c.g + c.b) * (1. / 3.);
		float gray = (1.5) * brightness;
		c = vec4(gray, gray, gray, c.a) * vec4(0.8,1.2,1.5,1);
		gl_FragColor =c;
	}
	else
	{
		vec4 cc = texture2D(u_texture, v_texCoord);
		gl_FragColor = cc;
	}
}