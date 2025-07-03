//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "HorseTestApp.h"
#include "HorseApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
HorseTestApp::validParams()
{
  InputParameters params = HorseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

HorseTestApp::HorseTestApp(const InputParameters & parameters) : MooseApp(parameters)
{
  HorseTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

HorseTestApp::~HorseTestApp() {}

void
HorseTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  HorseApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"HorseTestApp"});
    Registry::registerActionsTo(af, {"HorseTestApp"});
  }
}

void
HorseTestApp::registerApps()
{
  registerApp(HorseApp);
  registerApp(HorseTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
HorseTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  HorseTestApp::registerAll(f, af, s);
}
extern "C" void
HorseTestApp__registerApps()
{
  HorseTestApp::registerApps();
}
