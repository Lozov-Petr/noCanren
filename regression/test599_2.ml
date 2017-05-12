open Test599meta
open Printf

class type virtual
      [ 'heck
      , 'type_itself
      , 'gt_a_for_a, 'gt_a_for_b
      , 'inh,'syn]
      t_meta_tt = object
  method c_OK : 'inh ->
                ( 'inh,
                  'type_itself,
                  'syn,
                  'heck) GT.a ->
                'gt_a_for_a ->
                'syn
  method c_Error :  'inh ->
                    ( 'inh,
                      'type_itself,
                      'syn,
                      'heck) GT.a ->
                    'gt_a_for_b ->
                    'syn
  (* we omitted from meta_tt a method for type itself *)
end

class type virtual ['a,'a_inh,'a_syn,'inh,'syn] t2_tt
  = object
  inherit [ < a: 'a_inh -> 'a -> 'a_syn >
          , 'a t2
          ,   ( 'a_inh, 'a, 'a_syn,
              <
                a: 'a_inh -> 'a -> 'a_syn
              > ) GT.a
          , string
          , 'inh,'syn] t_meta_tt
    method  t_t2 :
      ('a_inh -> 'a -> 'a_syn) ->
      'inh ->
      'a t2 ->
      'syn
  end

let (t2 :
  ( ('a_inh -> 'a -> 'a_syn) ->
    ('a,'a_inh,'a_syn,'inh,'syn)#t2_tt ->
    'inh ->
    'a t2 ->
    'syn, unit)
    GT.t)
  =
  let rec
    t2_gcata
      transform_a
      transformer initial_inh subject =
    let parameter_transforms_obj = object method a = transform_a end
    in
    t_meta_gcata
      (fun arg0 -> GT.make transform_a arg0 parameter_transforms_obj)
      (fun arg0 -> arg0)
      parameter_transforms_obj
      transformer initial_inh subject
  in
  { GT.gcata = t2_gcata; plugins = () }

class virtual ['a,'a_inh,'a_syn,'inh,'syn] t2_t =
  object (this)
    method virtual  c_OK :
      'inh ->
      ( 'inh,
        'a t2,
        'syn,
        <
          a: 'a_inh -> 'a -> 'a_syn
        > ) GT.a ->
      ( 'a_inh,
        'a,
        'a_syn,
        <
          a: 'a_inh -> 'a -> 'a_syn
        > ) GT.a ->
      'syn
    method virtual  c_Error :
      'inh ->
      ( 'inh,
        'a t2,
        'syn,
        <
          a: 'a_inh -> 'a -> 'a_syn
        > ) GT.a ->
        string ->
        'syn
    method t_t2 transform_a =
      GT.transform t2 transform_a this
  end

class ['a] show_result2 = object(this)
  inherit  ['a,unit,string,unit,string] t2_t
  method c_OK    () : _ -> _ -> string
    = fun _subj p0 -> sprintf "OK %s" (p0.GT.fx ())
  method c_Error () : _ -> _ -> string
    = fun _subj p1 -> sprintf "Error %s"
                        (GT.lift (GT.string.GT.plugins)#show () p1)
                        (* (p1.GT.fx ()) *)
  method qqqq fa  : unit -> 'a t2 -> string = fun () ->
    GT.transform t2 fa this ()
end

let () =
  let show fa fb (e: _ t2) =
    t2.GT.gcata (GT.lift fa) (new show_result2) () e in
  printf "%s\n%!" (show string_of_float id (OK 1.));
  printf "%s\n%!" (show string_of_int id (Error "asdf"));
  ()
