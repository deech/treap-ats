#include "share/atspre_staload.hats"
staload STDLIB = "libats/libc/SATS/stdlib.sats"

datatype treap =
  | treap_nil
  | treap_cons of
    (@{x=int,y=lint}, treap, treap)

typedef split_result = @{lower=treap, equal=treap, greater=treap}

extern fun merge(
  lower: treap,
  greater: treap
): treap

implement merge(lower,greater) =
  case+ (lower,greater) of
    | (treap_nil(),g) => g
    | (l, treap_nil()) => l
    | (treap_cons(lp,ll,lr), treap_cons(gp,gl,gr)) =>
         if (lp.y < gp.y)
         then treap_cons(lp,ll,merge(lr, greater))
         else treap_cons(gp,merge(lower,gl),gr)

extern fun split_binary(
  t : treap,
  value : int
):(treap, treap)

implement split_binary(t,value) =
  case+ t of
    | treap_nil() =>  (treap_nil(), treap_nil())
    | treap_cons(p,l,r) =>
       if (p.x < value) then
         let
           val (new_l,new_r) = split_binary(r,value)
         in
           (treap_cons(p,l,new_l), new_r)
         end
       else
         let
           val (new_l,new_r) = split_binary(l,value)
         in
           (new_l, treap_cons(p,new_r,r))
         end

extern fun merge3 (
   r : split_result
): treap

implement merge3(r) = merge((merge(r.lower,r.equal)), r.greater)

extern fun split(
  orig : treap,
  value : int
) : split_result

implement split(orig, value) =
  let
    val+ (l,equal_greater) = split_binary(orig,value)
    val+ (eq, g) = split_binary(equal_greater, value+1)
  in
    @{lower=l,equal=eq,greater=g}
  end

extern fun has_value(
  t : treap,
  x : int
): (treap, bool)

implement has_value(t,x) =
  let
    val leg = split(t,x)
    val merged = merge3(leg)
  in
    case+ leg.equal of
      | treap_cons(_,_,_) => (merged, true)
      | treap_nil() => (merged, false)
  end

extern fun new_treap(
  x : int
) : treap

implement new_treap(x) =
  let
    val seed = $STDLIB.random()
  in
    treap_cons(@{x=x,y=seed},treap_nil(),treap_nil())
  end

extern fun insert(
  t : treap,
  x : int
): treap

implement insert(t,x) =
  let
    val leg = split(t,x)
  in
    case+ leg.equal of
      | treap_cons(_,_,_) => merge3(leg)
      | treap_nil() =>
          let
            val new = new_treap(x)
          in
            merge3(@{lower=leg.lower, equal=new, greater=leg.greater})
          end
  end

extern fun erase(
  t : treap,
  x : int
) : treap

implement erase(t,x) =
  let
    val leg = split(t,x)
  in
    merge(leg.lower,leg.greater)
  end

extern fun empty():treap
implement empty() = treap_nil()

implement main0(argc,argv) =
  let
    fun loop(
      t : treap,
      i : int,
      curr : int,
      res : int
    ):int =
      case i of
        | i when i = (1000000 - 1) => res
        | _ =>
          let
            val curr = (curr * 57 + 43) mod 10007
            val i = i + 1
          in
            case (i mod 3) of
              | 0 => loop(insert(t,curr),i,curr,res)
              | 1 => loop(erase(t,curr),i,curr,res)
              | 2 =>
                let
                  val (t,found)  = has_value(t,curr)
                in
                  if found then loop(t,i,curr,res+1)
                  else loop(t,i,curr,res)
                end
              | _ => loop(t,i,curr,res)

           end
  in
    println! (loop(empty(),1,5,0));
  end
