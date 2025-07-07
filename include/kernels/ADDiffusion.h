#pragma once

#include "ADKernelGrad.h"

class ADDiffusion : public ADKernelGrad
{
public:
  static InputParameters validParams();

  ADDiffusion(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;
};