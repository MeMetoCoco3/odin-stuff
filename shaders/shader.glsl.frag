#version 460

layout(location=0) out vec4 color;

void main(){
  vec2 frag_pos = gl_FragCoord.xy;
  float x = frag_pos.x;
  float y = frag_pos.y;

  float width = 1280.0; 
  float height = 780.0;

  color = vec4(x / width, y / height, x / height, 1.0);


}
