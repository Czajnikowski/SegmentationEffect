//
//  SegmentationEffect.metal
//  SegmentationEffectExample
//
//  Created by Maciek Czarnik on 05/03/2024.
//

#include <metal_stdlib>
using namespace metal;

float3x3 to3D(float2x2 mat) {
  return float3x3(
    float3(mat[0], 0),
    float3(mat[1], 0),
    float3(0, 0, 1)
  );
}

float3 to3d(float2 f) {
  return float3(f, 0);
}

float2x2 scale(float2 s) {
  return float2x2(
    s.x, 0,
    0, s.y
  );
}

float2x2 scaleX(float x) {
  return scale(float2(x, 1));
}

float2x2 scaleY(float y) {
  return scale(float2(1, y));
}

float wedge2D(float2 v, float2 w) {
  return v.y*w.x - v.x*w.y;
}

struct quadrilateral {
  float2 a, b, c, d;
};

float2 bilinearInterpolate(float2 p, quadrilateral q) {
  float2 uv;
  
  float2 e = q.d-q.c;
  float2 f = q.b-q.c;
  float2 g = q.c-q.d+q.a-q.b;
  float2 h = p-q.c;
  
  float A = wedge2D(g, f);
  float B = wedge2D(e, f) + wedge2D(h, g);
  float C = wedge2D(h, e);
  
  if(abs(A) < 0.00001) {
    uv = float2((h.x*B + f.x*C) / (e.x*B - g.x*C), -C/B);
  } else {
    float discriminant = B*B - 4.0*A*C;
    if(discriminant < 0.0) return float2(-1.0);
    discriminant = sqrt(discriminant);
    
    float iA = 0.5/A;
    float v = (-B - discriminant) * iA;
    float u = (h.x - f.x*v) / (e.x + g.x*v);
    if( u<0.0 || u>1.0 || v<0.0 || v>1.0 ) {
      v = (-B + discriminant)*iA;
      u = (h.x - f.x*v)/(e.x + g.x*v);
    }
    
    uv = float2(u, v);
  }
  
  return uv;
}


float3x3 inverse(float3x3 m) {
  float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
  float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
  float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];

  float b01 = a22 * a11 - a12 * a21;
  float b11 = -a22 * a10 + a12 * a20;
  float b21 = a21 * a10 - a11 * a20;

  float det = a00 * b01 + a01 * b11 + a02 * b21;

  return float3x3(
    b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
    b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
    b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)
  ) / det;
}

float3x3 translateY(float y) {
  return float3x3(
    1, 0, 0,
    0, 1, 0,
    0, y, 1
  );
}

float insideUnitSquare(float2 p) {
  float2 uv = step(0, p) * step(0, 1 - p);
  return uv.x * uv.y;
}

float2 transform(float2 p, float3x3 matrix) {
  return (matrix * float3(p, 1)).xy;
}

float2 segment(
  float2 position,
  quadrilateral q,
  float currentYOffset,
  float currentYScale
) {
  float2 currentInterpolation = bilinearInterpolate(position, q);
  float3x3 move = translateY(currentYOffset) * to3D(scaleY(currentYScale));
  return clamp(
    fract(move * float3(currentInterpolation, 1)).xy * insideUnitSquare(currentInterpolation),
    0,
    1
  );
}

constant float3x3 sharedNormalize = translateY(1) * to3D(scaleY(-1));
constant int countOfFloatsPerSegment = 5;

[[ stitchable ]] float2 segmentationEffect(
  float2 position,
  float4 boundingRect,
  device const float *segmentFloats,
  int countOfFloats,
  float verticalOffset
) {
  // (0, 0) - bottom-left, (1, 1) - top-right
  float3x3 normalize = sharedNormalize * to3D(scale(1 / boundingRect.zw));
  position = transform(position, normalize);
  
  quadrilateral currentQuadrilateral = quadrilateral {
    .c = float2(0, 1),
    .d = float2(1, 1),
  };
  float currentYScale = 1;
  float currentYOffset = 0;
  
  float2 result = 0;
  
  for(
    int intexOfFirstFloatInSegment = 0;
    intexOfFirstFloatInSegment < countOfFloats;
    intexOfFirstFloatInSegment += countOfFloatsPerSegment
  ) {
    float2 stepPointC = float2(
      segmentFloats[intexOfFirstFloatInSegment + 0],
      segmentFloats[intexOfFirstFloatInSegment + 1]
    );
    float2 stepPointD = float2(
      segmentFloats[intexOfFirstFloatInSegment + 2],
      segmentFloats[intexOfFirstFloatInSegment + 3]
    );
    currentYScale = segmentFloats[intexOfFirstFloatInSegment + 4];
    currentYOffset -= currentYScale;
    
    currentQuadrilateral = quadrilateral {
      .a = currentQuadrilateral.d,
      .b = currentQuadrilateral.c,
      .c = transform(stepPointC, normalize),
      .d = transform(stepPointD, normalize),
    };
    
    if(result.x * result.y == 0) {
      result = segment(
        position,
        currentQuadrilateral,
        currentYOffset,
        currentYScale
      );
    }
  }

  currentQuadrilateral = {
    .a = currentQuadrilateral.d,
    .b = currentQuadrilateral.c,
    .c = 0,
    .d = float2(1, 0),
  };
  
  if(result.x * result.y == 0) {
    result = segment(
      position,
      currentQuadrilateral,
      currentYOffset - currentYScale,
      currentYScale
    );
  }
  
  if(result.x * result.y == 0) {
    discard_fragment();
  }
  
  result.y = fract(result.y + verticalOffset / 10);

  return (inverse(normalize) * float3(result, 1)).xy;
}
