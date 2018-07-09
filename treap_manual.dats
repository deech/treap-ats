#include "share/atspre_staload.hats"
staload STDLIB = "libats/libc/SATS/stdlib.sats"

datavtype treap_vt =
  | treap_vt_nil
  | treap_vt_cons of (int,lint,treap_vt,treap_vt)

extern fun free_treap(
  t : treap_vt
) : void

implement free_treap(t) =
  case+ t of
   | ~treap_vt_cons(_,_,l,r) => (free_treap(l); free_treap(r); ())
   | ~treap_vt_nil() => ()

extern fun merge(
  lower: treap_vt,
  greater: treap_vt
): treap_vt

implement merge(lower,greater) =
  let
    var res : treap_vt
    fun loop (
          lower: treap_vt,
          greater: treap_vt,
          res: &treap_vt? >> treap_vt
        ) : void =
        case+ (lower,greater) of
          | (~treap_vt_nil(), ~treap_vt_nil()) => res := treap_vt_nil()
          | (l, ~treap_vt_nil()) => res := l
          | (~treap_vt_nil(), g) => res := g
          | (@treap_vt_cons(_,ly,_,lr), @treap_vt_cons(_,gy,gl,_)) =>
              if (ly < gy)
              then
                let
                  val lr_ = lr
                in
                  begin
                    res := lower;
                    fold@(greater);
                    loop(lr_,greater,lr);
                    fold@(res)
                  end
                end
              else
                let
                  val gl_ = gl
                in
                  begin
                    res := greater;
                    fold@(lower);
                    loop(lower,gl_,gl);
                    fold@(res)
                  end
                end
    val () = loop(lower,greater,res)
  in
    res
  end

extern fun split_binary(
  t : treap_vt,
  i : int
): (treap_vt, treap_vt)

implement split_binary(t,i) =
  let
    fun loop (
          curr : treap_vt
        ): (treap_vt, treap_vt) =
        case+ curr of
          | ~treap_vt_nil() => (treap_vt_nil(),treap_vt_nil())
          | @treap_vt_cons(lx,_,ll,lr) =>
              if (lx < i) then
                let
                  val _lr = lr
                  val (l,r) = loop(_lr)
                in
                  begin
                    lr := l;
                    fold@(curr);
                    (curr,r)
                  end
                end
              else
                let
                  val _ll = ll
                  val (l,r) = loop(_ll)
                in
                  begin
                    ll := r;
                    fold@(curr);
                    (l,curr)
                  end
                end
  in
    loop(t)
  end

extern fun merge3(
  l : treap_vt,
  eq : treap_vt,
  g : treap_vt
): treap_vt

implement merge3(l,eq,g) =
  merge(merge(l,eq),g)

extern fun split(
  t: treap_vt,
  i: int
): (treap_vt,treap_vt,treap_vt)

implement split(t,i) =
  let
    val+ (l,eq_gr) = split_binary(t,i)
    val+ (eq,gr) = split_binary(eq_gr,i+1)
  in
    (l,eq,gr)
  end

extern fun has_value(
  t: treap_vt,
  i: int
): (treap_vt, bool)

implement has_value(t,i) =
  let
    val+(l,eq,g) = split(t,i)
  in
    case+ eq of
      | ~treap_vt_nil() => (merge(l,g),false)
      | eq => (merge3(l,eq,g),true)
  end

extern fun new_treap(
  i: int
): treap_vt

implement new_treap(i) =
  treap_vt_cons(i,$STDLIB.random(),treap_vt_nil(),treap_vt_nil())

extern fun insert(
  t: treap_vt,
  i: int
): treap_vt

implement insert(t,i) =
  let
    val+(l,eq,g) = split(t,i)
  in
    case+ eq of
      | ~treap_vt_nil() => merge3(l,new_treap(i),g)
      | _ => merge3(l,eq,g)
  end

extern fun erase(
  t : treap_vt,
  i : int
) : treap_vt

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
      t: treap_vt,
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
    println! (loop(treap_vt_nil(),1,5,0))
  end
