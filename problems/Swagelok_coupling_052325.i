[Mesh]
    [./swagelok] 
        type = FileMeshGenerator 
        file= 'Swagelok_060925.e'
        
    []
[]
[GlobalParams]
    displacements = 'disp_x disp_y disp_z'
[]
[AuxVariables]
    [temp]
    []
    [theta]
    []
    [period]
    []
    [amplitude]
    []  
[]



[AuxKernels] 
    [temperature_function] 
        type= FunctionAux 
        variable= temp
        function = 82.22 # (C) 180 F temperature for lube oil

        #function = 82.22 # (C) 180 F temperature for lube oil
        
    []
    [theta_function]
        type = FunctionAux
        variable= theta
        function = (3.1415/4)
    []
    [period_function]
        type = FunctionAux
        variable = period
        function = 2*3.1415*15
    []
    [amplitude_function]
        type = FunctionAux
        variable = amplitude
        function = 0.00011
    []
[]

[Physics/SolidMechanics/QuasiStatic]
    [all]
      add_variables = true
      strain = FINITE
      volumetric_locking_correction = true
      automatic_eigenstrain_names= true
      generate_output= 'stress_xx stress_yy stress_zz stress_xy stress_yz stress_zx vonmises_stress'
    
    []
[] 

[BCs]    
    [./fixed_x]
      type = DirichletBC
      variable = disp_x
      boundary = fixed
      value = 0.0
    [../]
    [./fixed_y]
        type = DirichletBC
        variable = disp_y
        boundary = fixed
        value = 0.0
    [../]
    [./fixed_z]
        type = DirichletBC
        variable = disp_z
        boundary = fixed
        value = 0.0
    [../]  
    [./fixed_neumann_disp_x]
        type = NeumannBC
        variable = disp_x
        boundary = fixed_neumann
        value = 0.0
    [../]
    [./fixed_neumann_disp_y]
            type = NeumannBC
            variable = disp_y
            boundary = fixed_neumann
            value = 0.0
    [../]
    [./fixed_neumann_disp_z]
            type = NeumannBC
            variable = disp_z
            boundary = fixed_neumann
            value = 0.0
    [../]
    [./time_dependent_disp_BC_load_disp_y]
            type = FunctionDirichletBC
            variable = disp_y
            boundary = load
            function = 'amplitude* sin(period*t)* sin(theta)'   #peak displacement of 0.11 mm and frequency is 10-500Hz
    [../]
    
    [./time_dependent_disp_BC_load_disp_z]
            type = FunctionDirichletBC
            variable = disp_z
            boundary = load
            function = 'amplitude* sin(period*t)* sin(theta)'   
    [../]

    [./Pressure]
        
        [./internal_1]
            boundary = internal_1 
            factor= 689475.729 # (Pa) less than 100 psi
            displacements = 'disp_x disp_y disp_z'
        [../]
        [./internal_2]
            boundary = internal_2
            factor= 689475.729 # (Pa) less than 100 psi
            displacements = 'disp_x disp_y disp_z'
        [../]
        [./internal_3]
            boundary = internal_3
            factor= 689475.729 # (Pa) less than 100 psi
            displacements = 'disp_x disp_y disp_z'
        [../]
        [./internal_4]
            boundary = internal_4
            factor= 689475.729 # (Pa) less than 100 psi
            displacements = 'disp_x disp_y disp_z'
        [../]
        [./internal_5]
            boundary = internal_5
            factor= 689475.729 # (Pa) less than 100 psi
            displacements = 'disp_x disp_y disp_z'
        [../]
        [./internal_6]
            boundary = internal_6
            factor= 689475.729 # (Pa) less than 100 psi
            displacements = 'disp_x disp_y disp_z'
        [../]
        
        
        
    [../]
[]


[Materials]
    [./youngs_modulus_fnc]
        type= PiecewiseLinearInterpolationMaterial
        x= '82.22 100'
        y= '33000000 30000000'
        property= youngs_modulus_fnc
        variable= temp


    [../]
    [./poissons_ratio_fnc]
        type= PiecewiseLinearInterpolationMaterial
        x= '82.22 100'
        y= '0.34 0.30'
        property= poissons_ratio_fnc
        variable= temp
        

    [../]
    [elasticity_tensor]
        type = ComputeVariableIsotropicElasticityTensor
        args= temp
        youngs_modulus = youngs_modulus_fnc
        poissons_ratio = poissons_ratio_fnc
    []
    
    [thermal_expansion] 
        type= ComputeMeanThermalExpansionFunctionEigenstrain
        eigenstrain_name = thermal_expansion
        thermal_expansion_function = brass_thermal_expansion_function
        thermal_expansion_function_reference_temperature = 20
        temperature = temp    
        stress_free_temperature = 15  #Ambient temperature  
    []
    [stress]
      #type= ComputeLinearElasticStress
        type = ComputeFiniteStrainElasticStress
    []
[]
  
[Functions]
    [./brass_thermal_expansion_function]
        type = ParsedFunction
        symbol_names = 'tsf tref scale' #stress free temp, reference temp, scale factor
        symbol_values = '15 20  1.92e-5' #thermal_expansion_coeff = 1.92e-5 at 20 C 
        expression = 'scale * (t - tsf) / (t - tref)'
      [../]
[]
  
[Executioner]
    type = Transient
    


    nl_rel_tol = 1e-6      
    nl_abs_tol = 1e-8
    l_tol = 1e-4
    solve_type = NEWTON     
    line_search = bt        
  
    petsc_options_iname = '-pc_type -pc_hypre_type -ksp_type -ksp_gmres_restart -ksp_rtol'
    petsc_options_value = 'hypre boomeramg gmres 30 1e-4'
  
    nl_max_its = 30         
    automatic_scaling = true 
    start_time = 0.0
    num_steps = 100
    dt = 0.001
    [Predictor]
      type = SimplePredictor
      scale = 1
    []
[]
  
[VectorPostprocessors]
    
    
    [./soln_left_surface] 
        type = SideValueSampler
        variable = 'vonmises_stress'
        boundary = left
        sort_by = y
    
    []
    [./soln_middle_surface] 
        type = SideValueSampler
        variable = 'vonmises_stress'
        boundary = middle
        sort_by = y
    
    []
    [./soln_right_surface] 
        type = SideValueSampler
        variable = 'vonmises_stress'
        boundary = right
        sort_by = y
    
    []
[]

[Postprocessors]
    [sim_time]
        type = TimePostprocessor
    []
    [max_von_mises_stress]
        type = ElementExtremeValue
        variable= vonmises_stress
        value_type=max
    []
[]


[Outputs]
    file_base = Swagelok_060925_results
    exodus = true
    print_linear_residuals = true

    #[./csv]
    #type = CSV
    #[../]
[]
[Debug]
    show_var_residual_norms = true
[]