let pppt_int : (Format.formatter -> int -> unit) = (fun fmt -> Format.fprintf fmt "%d")

let pppt_string : (Format.formatter -> string -> unit) = (fun fmt -> Format.fprintf fmt "%s" )

type ('a,'b) pair = 'a * 'b

type 'a logic = Value of 'a | Var of int
[@@deriving showT {with_path=false}]

(* type 'a list = Nil | Cons of 'a * 'a list
[@@deriving showT {with_path=false}] *)

(* type pair = int * string *)
(* [@@deriving showT {with_path=false}] *)

(* type 'a logic = Var of int (* * 'a logic list *)
              | Value of 'a
(* [@@deriving showT {with_path=false}] *)
;;

let rec pppt_logic :
          'a .
            (string * (Format.formatter -> 'a -> Ppx_deriving_runtime.unit))
              ->
              (string *
                (Format.formatter -> 'a logic -> Ppx_deriving_runtime.unit))
  =
  ((let open! Ppx_deriving_runtime in
      fun (typ_a,poly_a)  ->
        let full_typ_name = (Printf.sprintf "(%s) logic") typ_a  in
        (full_typ_name,
          (fun fmt  ->
             function
             | Var a0 ->
                 (Format.fprintf fmt "(@[<2>Var@ ";
                  snd
                    ((fst ("int", (fun fmt  -> Format.fprintf fmt "%d"))),
                      (snd ("int", (fun fmt  -> Format.fprintf fmt "%d")) a0));
                  Format.fprintf fmt "@])")
             | Value a0 ->
                 (Format.fprintf fmt "(@[<2>Value@ ";
                  snd ((fst (poly_a fmt)), (snd (poly_a fmt) a0));
                  Format.fprintf fmt "@])"))))
  [@ocaml.warning "-A"])

and show_logic :
  'a .
    (string * (Format.formatter -> 'a -> Ppx_deriving_runtime.unit)) ->
      'a logic -> Ppx_deriving_runtime.string
  =
  fun (typ_a,poly_a)  ->
    fun x  -> Format.asprintf "%a" (snd (pppt_logic (typ_a, poly_a))) x


(* and show_logic :
  'a .
    (string * (Format.formatter -> 'a -> Ppx_deriving_runtime.unit)) ->
      'a logic -> Ppx_deriving_runtime.string
  =
  fun (typ_a,poly_a)  ->
    fun x  -> Format.asprintf "%a" (snd (pppt_logic (typ_a, poly_a))) x *)

(*
let rec pppt_logic : string * (Format.formatter -> 'a -> unit) ->
  string *  (Format.formatter -> 'a logic -> unit) = fun (argname, pp_arg) ->
  ( Printf.sprintf "%s logic" argname
  , fun fmt -> function
    | Var (n,cs) -> Format.fprintf fmt "(_.%d %a: %s)" n
        (fun fmt -> function
          | [] -> ()
          | xs -> Format.fprintf fmt "{{";
                  List.iter (snd (pppt_logic (argname, pp_arg)) fmt) xs;
                  Format.fprintf fmt "}}"
          )
        cs
        argname
    | Value x ->
        Format.fprintf fmt "Value (";
        pp_arg fmt x;
        Format.fprintf fmt ")"
  )
*)

let () =
  Format.fprintf Format.std_formatter "%a\n%!" (pppt_logic pppt_int    |> snd ) (Value 1);
  Format.fprintf Format.std_formatter "%a\n%!" (pppt_logic pppt_int    |> snd ) (Var   (2));
  Format.fprintf Format.std_formatter "%a\n%!" (pppt_logic pppt_string |> snd ) (Var  (33));
  ()
(*
type ('a, 'b) glist = Nil | Cons of 'a * 'b
(* [@@deriving showT] *)

let pppt_glist:  string * (Format.formatter -> 'a -> unit) ->
    string * (Format.formatter -> 'b -> unit) ->
    string * (Format.formatter -> ('a,'b) glist -> unit) = fun (typ1, pp1) (typ2, pp2) ->
  ( Printf.sprintf "(%s,%s) llist" typ1 typ2
  , fun fmt -> function
    | Nil -> Format.fprintf fmt "[]"
    | Cons (a,b) -> Format.fprintf fmt "%a :: %a" pp1 a pp2 b
  )

type 'a list = ('a, 'a list) glist

let rec pppt_list : string * (Format.formatter -> 'a -> unit) ->
  string * (Format.formatter -> 'a list -> unit) = fun (typ1, pp1) ->
  pppt_glist (typ1,pp1)
    ( Printf.sprintf " %s list" typ1
    , fun fmt xs -> (snd @@ pppt_list (typ1,pp1)) fmt xs )

let rec pppt_intlogic_list : string * (Format.formatter -> int logic list -> unit) =
  ("int logic list"
  , fun fmt xs -> (pppt_list (pppt_logic pppt_int) |> snd) fmt xs
  )

type 'a llist = ('a, 'a llist) glist logic
let rec pppt_intlogic_llist : string * (Format.formatter -> int logic llist -> unit) =
  ("int logic llist"
  , fun fmt -> (snd @@ pppt_logic (pppt_glist (pppt_logic pppt_int) pppt_intlogic_llist)) fmt
  )


let () =
  Format.fprintf Format.std_formatter "%a\n%!" (pppt_list  pppt_string |> snd )
    (Cons ("a", Cons ("b", Nil)));
  Format.fprintf Format.std_formatter "%a\n%!" (pppt_intlogic_list |> snd )
    (Cons (Value 10, Cons (Var (1,[]), Nil)));
  Format.fprintf Format.std_formatter "%a\n%!" (pppt_intlogic_llist |> snd )
    (Value (Cons (Value 10, Value (Cons (Value 20, Var (21,[Var (20,[])]))))));
*) *)