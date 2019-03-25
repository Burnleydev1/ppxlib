open! Import

class map = object
  inherit Ppxlib_traverse_builtins.map
  inherit Ast.map
end

class iter = object
  inherit Ppxlib_traverse_builtins.iter
  inherit Ast.iter
end

class ['acc] fold = object
  inherit ['acc] Ppxlib_traverse_builtins.fold
  inherit ['acc] Ast.fold
end

class ['acc] fold_map = object
  inherit ['acc] Ppxlib_traverse_builtins.fold_map
  inherit ['acc] Ast.fold_map
end

class ['ctx] map_with_context = object
  inherit ['ctx] Ppxlib_traverse_builtins.map_with_context
  inherit ['ctx] Ast.map_with_context
end

class virtual ['res] lift = object
  inherit ['res] Ppxlib_traverse_builtins.lift
  inherit ['res] Ast.lift
end

let enter name path = if String.is_empty path then name else path ^ "." ^ name

class map_with_path = object
  inherit [string] map_with_context as super

  (* WAS:
     method! structure_item_desc path x =
     match x with
     | Pstr_module mb -> super#structure_item_desc (enter mb.pmb_name.txt path) x
     | _ -> super#structure_item_desc path x

     Overriding [module_binding] seems to be OK because it does not catch
     local module bindings because at the moment the parsetree doesn't make
     use of [module_binding] for local modules, but that might change in the
     future, so this might be something to keep in mind.

     The following:

         module A = struct .. end
         module A = struct .. end

     is disallowed, but

         let _ = .. let module A = struct .. end in ..
         module A = struct .. end
         let _ = .. let module A = struct .. end in ..

     isn't, and the "path" constructed here would be able to differentiate
     between them. *)
  method! module_binding path mb =
       super#module_binding (enter mb.pmb_name.txt path) mb

  method! module_declaration path md =
    super#module_declaration (enter md.pmd_name.txt path) md

  method! module_type_declaration path mtd =
    super#module_type_declaration (enter mtd.pmtd_name.txt path) mtd
end

let var_names_of = object
  inherit [string list] fold as super

  method! pattern p acc =
    let acc = super#pattern p acc in
    match p.ppat_desc with
    | Ppat_var {txt; _} -> txt :: acc
    | _ -> acc
end

class map_with_code_path = object (self)
  inherit [Code_path.t] map_with_context as super

  method! module_binding path mb =
       super#module_binding (Code_path.enter mb.pmb_name.txt path) mb

  method! module_declaration path md =
    super#module_declaration (Code_path.enter md.pmd_name.txt path) md

  method! module_type_declaration path mtd =
    super#module_type_declaration (Code_path.enter mtd.pmtd_name.txt path) mtd

  method! value_description path vd =
    super#value_description (Code_path.enter vd.pval_name.txt path) vd

  method! value_binding path {pvb_pat; pvb_expr; pvb_attributes; pvb_loc} =
    let all_var_names = var_names_of#pattern pvb_pat [] in
    let var_name = Base.List.last all_var_names in
    let in_binding_path =
      Base.Option.fold var_name ~init:path ~f:(fun path var_name -> Code_path.enter var_name path)
    in
    let pvb_pat = self#pattern path pvb_pat in
    let pvb_expr = self#expression in_binding_path pvb_expr in
    let pvb_attributes = self#attributes in_binding_path pvb_attributes in
    let pvb_loc = self#location path pvb_loc in
    { pvb_pat; pvb_expr; pvb_attributes; pvb_loc }
end

class sexp_of = object
  inherit [Sexp.t] Ast.lift

  method int       = sexp_of_int
  method string    = sexp_of_string
  method bool      = sexp_of_bool
  method char      = sexp_of_char
  method float     = sexp_of_float
  method int32     = sexp_of_int32
  method int64     = sexp_of_int64
  method nativeint = sexp_of_nativeint
  method unit      = sexp_of_unit
  method option    = sexp_of_option
  method list      = sexp_of_list
  method array : 'a. ('a -> Sexp.t) -> 'a array -> Sexp.t = sexp_of_array

  method other : 'a. 'a -> Sexp.t = fun _ -> Sexp.Atom "_"

  method record fields =
    List (List.map fields ~f:(fun (label, sexp) ->
      Sexp.List [Atom label; sexp]))

  method constr tag args =
    match args with
    | [] -> Atom tag
    | _  -> List (Atom tag :: args)

  method tuple l = List l
end

let sexp_of = new sexp_of
