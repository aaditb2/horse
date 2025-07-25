[Mesh]
    [./swagelok] 
        type = FileMeshGenerator 
        file= 'Swagelok_060925.e'
        
    []
[]
[GlobalParams]
    displacements = 'disp_x disp_y disp_z'
    absolute_value_vector_tags = 'ref'
    origin = '0 0 0'
    direction = '0 0 1'
    polar_moment_of_inertia = pmi
    factor = t

[]

[Problem]
    type = ReferenceResidualProblem
    extra_tag_vectors = 'ref'
    reference_vector = 'ref'
    group_variables = 'disp_x disp_y disp_z'
[]
[AuxVariables]
    [temp]
    []  
[]



[AuxKernels] 
    [temperature_function] 
        type= FunctionAux 
        variable= temp
        function = 82.22 # (C) 180 F temperature for lube oil

        #function = 82.22 # (C) 180 F temperature for lube oil
        
    []
[]

[Physics/SolidMechanics/QuasiStatic]
    [all]
      add_variables = true
      strain = FINITE
      volumetric_locking_correction = true
      automatic_eigenstrain_names= true
      generate_output= 'stress_xx stress_yy stress_zz stress_xy stress_yz stress_zx vonmises_stress max_principal_stress hoop_stress axial_stress radial_stress'
      cylindrical_axis_point1 = '0 0 0'
      cylindrical_axis_point2 = '1 0 0'
      material_output_order = FIRST
      material_output_family = MONOMIAL
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
            function = '0.00011* sin(2*3.1415*15*t)* 0.707'   #peak displacement of 0.11 mm and frequency is 10-500Hz
    [../]
    
    [./time_dependent_disp_BC_load_disp_z]
            type = FunctionDirichletBC
            variable = disp_z
            boundary = load
            function = '0.00011* sin(2*3.1415*15*t)* 0.707'   
    [../]
    #torque addition
    [./twist_x]
            type = Torque
            boundary = fixed
            variable = disp_x
    [../]
    
    [./twist_y]
            type = Torque
            boundary = fixed
            variable = disp_y
    [../]

    [./twist_z]
            type = Torque
            boundary = fixed
            variable = disp_z
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
  
[Preconditioning]
    [SMP]
      type = SMP
      full = true
    []
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
    [axial_stress]
        type = LineValueSampler
        start_point = '0 0.003175 0'
        end_point = '0 0.007143  0'
        num_points = 20
        outputs = csv
        sort_by = id
        use_displaced_mesh = false
        variable = axial_stress
    []
    [hoop_stress]
        type = LineValueSampler
        start_point = '0 0.003175  0'
        end_point = '0 0.007143  0'
        num_points = 20
        outputs = csv
        sort_by = id
        use_displaced_mesh = false
        variable = hoop_stress
    []
    [radial_stress]
        type = LineValueSampler
        start_point = '0 0.003175  0'
        end_point = '0 0.007143  0'
        num_points = 20
        outputs = csv
        sort_by = id
        use_displaced_mesh = false
        variable = radial_stress
    []
    [coefs_axial]
        type = LeastSquaresFitHistory
        contains_complete_history = true
        order = 4
        vectorpostprocessor = axial_stress
        x_name = id
        x_scale = 252.0161     #1/thickness to normalize
        x_shift = 0   #offset of first sampled point from inner surface
        y_name = axial_stress
    []
    [coefs_hoop]
        type = LeastSquaresFitHistory
        contains_complete_history = true
        order = 4
        vectorpostprocessor = hoop_stress
        x_name = id
        x_scale = 252.0161     #1/thickness to normalize
        x_shift = 0   #offset of first sampled point from inner surface
        y_name = hoop_stress
    []
    [coefs_radial]
        type = LeastSquaresFitHistory
        contains_complete_history = true
        order = 4
        vectorpostprocessor = radial_stress
        x_name = id
        x_scale = 252.0161     #1/thickness to normalize
        x_shift = 0   #offset of first sampled point from inner surface
        y_name = radial_stress
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
    [max_principal_stress]
        type = ElementExtremeValue
        variable= max_principal_stress
        value_type=max
    []
    [pmi]
    type = PolarMomentOfInertia
    boundary = fixed
    # execute_on = 'INITIAL NONLINEAR'
    execute_on = 'INITIAL'
  []
[]


[Outputs]
    wall_time_checkpoint = false
    file_base = Swagelok_071725_results
    exodus = true
    csv=true
    print_linear_residuals = true

    #[./csv]
    #type = CSV
    #[../]
[]
[Debug]
    show_var_residual_norms = true
[]