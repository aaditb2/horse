#include "HorseApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
HorseApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

HorseApp::HorseApp(const InputParameters & parameters) : MooseApp(parameters)
{
  HorseApp::registerAll(_factory, _action_factory, _syntax);
}

HorseApp::~HorseApp() {}

void
HorseApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<HorseApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"HorseApp"});
  Registry::registerActionsTo(af, {"HorseApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
HorseApp::registerApps()
{
  registerApp(HorseApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
HorseApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  HorseApp::registerAll(f, af, s);
}
extern "C" void
HorseApp__registerApps()
{
  HorseApp::registerApps();
}
