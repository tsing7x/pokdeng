#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;

uniform vec2 resolution;//ģ�������ʵ�ʷֱ���
uniform float blurRadius;//�뾶
uniform float sampleNum;//����Ķ���

uniform int flag; //���ƺͻָ�

vec4 blur(vec2);

void main(void)
{
    if(flag > 0){
        vec4 col = blur(v_texCoord); //* v_fragmentColor.rgb;
        gl_FragColor = vec4(col) * v_fragmentColor;
    }else{
        vec4 c = texture2D(u_texture, v_texCoord) * v_fragmentColor;
        gl_FragColor = c;
    }
}

vec4 blur(vec2 p)
{
    if (blurRadius > 0.0 && sampleNum > 1.0)
    {
        vec4 col = vec4(0);
        vec2 unit = 1.0 / resolution.xy;//��λ����

        float r = blurRadius;
        float sampleStep = r / sampleNum;

        float count = 0.0;
        //����һ�����Σ���ǰ������Ϊ���ĵ㣬����������ÿ�����ص����ɫ
        for(float x = -r; x < r; x += sampleStep)
        {
            for(float y = -r; y < r; y += sampleStep)
            {
                float weight = (r - abs(x)) * (r - abs(y));//Ȩ�أ�p���Ȩ����ߣ����������μ���
                col += texture2D(u_texture, p + vec2(x * unit.x, y * unit.y)) * weight;
                count += weight;
            }
        }
        //�õ�ʵ��ģ����ɫ��ֵ
        return col / count;
    }

    return texture2D(u_texture, p);
}