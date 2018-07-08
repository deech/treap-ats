#include "share/atspre_staload.hats"
staload STDLIB = "libats/libc/SATS/stdlib.sats"

datavtype treap_vt = treap_vt of (int,lint,Option_vt(treap_vt),Option_vt(treap_vt))

extern fun free_treap(
  t : Option_vt(treap_vt)
) : void

implement free_treap(t) =
  case+ t of
   | ~Some_vt(~treap_vt(_,_,l,r)) => (free_treap(l); free_treap(r); ())
   | ~None_vt() => ()

extern fun merge(
  lower: Option_vt(treap_vt),
  greater: Option_vt(treap_vt)
): Option_vt(treap_vt)

implement merge(lower,greater) =
  let
    var res : Option_vt(treap_vt)
    fun loop (
          lower: Option_vt(treap_vt),
          greater: Option_vt(treap_vt),
          res: &Option_vt(treap_vt)? >> Option_vt(treap_vt)
        ) : void =
        case+ (lower,greater) of
          | (~None_vt(), ~None_vt()) => res := None_vt()
          | (l, ~None_vt()) => res := l
          | (~None_vt(), g) => res := g
          | (Some_vt(l as treap_vt(_,ly,_,_)), Some_vt(g as treap_vt(_,gy,_,_))) =>
              if (ly < gy)
              then
                case+ l of
                  | @treap_vt(_,_,_,lr) =>
                    let
                      val lr_ = lr
                    in
                      begin
                        res := lower;
                        loop(lr_,greater,lr);
                        fold@(l)
                      end
                    end
              else
                case+ g of
                  | @treap_vt(_,_,gl,_) =>
                    let
                      val gl_ = gl
                    in
                      begin
                        res := greater;
                        loop(lower,gl_,gl);
                        fold@(g)
                      end
                    end
    val () = loop(lower,greater,res)
  in
    res
  end

extern fun split_binary(
  t : Option_vt(treap_vt),
  i : int
): (Option_vt(treap_vt), Option_vt(treap_vt))

implement split_binary(t,i) =
  let
    fun loop (
          curr : Option_vt(treap_vt)
        ): (Option_vt(treap_vt), Option_vt(treap_vt)) =
        case+ curr of
          | ~None_vt() => (None_vt(),None_vt())
          | Some_vt(t as treap_vt(lx,_,_,_)) =>
              if (lx < i) then
                case+ t of
                  | @treap_vt(_,_,_,lr) =>
                      let
                        val _lr = lr
                        val (l,r) = loop(_lr)
                      in
                        begin
                          lr := l;
                          fold@(t);
                          (curr,r)
                        end
                      end
              else
                case+ t of
                  | @treap_vt(_,_,ll,_) =>
                      let
                        val _ll = ll
                        val (l,r) = loop(_ll)
                      in
                        begin
                          ll := r;
                          fold@(t);
                          (l,curr)
                        end
                      end
  in
    loop(t)
  end

extern fun merge3(
  l : Option_vt(treap_vt),
  eq : Option_vt(treap_vt),
  g : Option_vt(treap_vt)
): Option_vt(treap_vt)

implement merge3(l,eq,g) =
  merge(merge(l,eq),g)

extern fun split(
  t: Option_vt(treap_vt),
  i: int
): (Option_vt(treap_vt),Option_vt(treap_vt),Option_vt(treap_vt))

implement split(t,i) =
  let
    val+ (l,eq_gr) = split_binary(t,i)
    val+ (eq,gr) = split_binary(eq_gr,i+1)
  in
    (l,eq,gr)
  end

extern fun has_value(
  t: Option_vt(treap_vt),
  i: int
): (Option_vt(treap_vt), bool)

implement has_value(t,i) =
  let
    val+(l,eq,g) = split(t,i)
  in
    case+ eq of
      | ~None_vt() => (merge(l,g),false)
      | eq => (merge3(l,eq,g),true)
  end

extern fun new_treap(
  i: int
): Option_vt(treap_vt)

implement new_treap(i) =
  Some_vt(treap_vt(i,$STDLIB.random(),None_vt(),None_vt()))

extern fun insert(
  t: Option_vt(treap_vt),
  i: int
): Option_vt(treap_vt)

implement insert(t,i) =
  let
    val+(l,eq,g) = split(t,i)
  in
    case+ eq of
      | ~None_vt() => merge3(l,new_treap(i),g)
      | _ => merge3(l,eq,g)
  end

extern fun erase(
  t : Option_vt(treap_vt),
  i : int
) : Option_vt(treap_vt)

implement erase(t,i) =
  let
    val+(l,eq,g) = split(t,i)
  in
    begin
      free_treap(eq);
      merge(l,g)
    end
  end

implement main0(argc,argv) =
  let
    fun loop(
      t: Option_vt(treap_vt),
      i: int,
      curr: int,
      res: int
    ):int =
      case+ i of
        | i when i >= 1000000 =>
          begin
            free_treap(t);
            res
          end
        | _ =>
          let
            val curr = (curr*57+43) mod 10007
            val i = i+1
          in
            case (i mod 3) of
              | 0 => loop(insert(t,curr),i,curr,res)
              | 1 => loop(erase(t,curr),i,curr,res)
              | 2 =>
                let
                  val+(t,found) = has_value(t,curr)
                in
                  if found then loop(t,i,curr,res+1)
                  else loop(t,i,curr,res)
                end
              | _ => loop(t,i,curr,res)
          end
  in
    println! (loop(None_vt(),1,5,0))
  end
