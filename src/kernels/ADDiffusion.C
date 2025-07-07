#include "ADDiffusion.h"

registerMooseObject("MooseApp", ADDiffusion);

InputParameters
ADDiffusion::validParams()
{
  auto params = ADKernelGrad::validParams();
  params.addClassDescription("Same as `Diffusion` in terms of physics/residual, but the Jacobian "
                             "is computed using forward automatic differentiation");
  return params;
}

ADDiffusion::ADDiffusion(const InputParameters & parameters) : ADKernelGrad(parameters) {}

ADRealVectorValue
ADDiffusion::precomputeQpResidual()
{
  return _grad_u[_qp];
}