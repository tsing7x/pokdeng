#ifdef GL_ES
    precision mediump float;
#endif
varying vec4 v_fragmentColor; 
varying vec2 v_texCoord; 
uniform sampler2D CC_Texture0;
uniform int flag; //控制和恢复
void main(void)
{
    vec4 c = texture2D(CC_Texture0, v_texCoord);
    
    if (flag >0)
    {
        float gray = dot(c.rgb,vec3(0.299,0.587,0.114));
        gl_FragColor.xyz = vec3(gray,gray,gray);
    }
    else
    {
        gl_FragColor.xyz = c.rgb;
    }
    
    gl_FragColor.w = c.w;
}