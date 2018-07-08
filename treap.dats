#include "share/atspre_staload.hats"
staload STDLIB = "libats/libc/SATS/stdlib.sats"

datatype treap = treap of (@{x=int,y=lint}, Option(treap), Option(treap))
typedef split_result = @{lower=Option(treap), equal=Option(treap), greater=Option(treap)}

extern fun merge(
  lower: Option(treap),
  greater: Option(treap)
): Option(treap)

implement merge(lower,greater) =
  case+ (lower,greater) of
    | (None(),g) => g
    | (l, None()) => l
    | (Some(treap(lp,ll,lr)), Some(treap(gp,gl,gr))) =>
         if (lp.y < gp.y)
         then Some(treap(lp,ll,merge(lr, greater)))
         else Some(treap(gp,merge(lower,gl),gr))

extern fun split_binary(
  t : Option(treap),
  value : int
):(Option(treap), Option(treap))

implement split_binary(t,value) =
  case+ t of
    | None() =>  (None(), None())
    | Some(treap(p,l,r)) =>
       if (p.x < value) then
         let
           val (new_l,new_r) = split_binary(r,value)
         in
           (Some(treap(p,l,new_l)), new_r)
         end
       else
         let
           val (new_l,new_r) = split_binary(l,value)
         in
           (new_l, Some(treap(p,new_r,r)))
         end

extern fun merge3 (
   r : split_result
): Option(treap)

implement merge3(r) = merge((merge(r.lower,r.equal)), r.greater)

extern fun split(
  orig : Option(treap),
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
  t : Option(treap),
  x : int
): (Option(treap), bool)

implement has_value(t,x) =
  let
    val leg = split(t,x)
    val merged = merge3(leg)
  in
    case+ leg.equal of
      | Some(_) => (merged, true)
      | None() => (merged, false)
  end

extern fun new_treap(
  x : int
) : Option(treap)

implement new_treap(x) =
  let
    val seed = $STDLIB.random()
  in
    Some(treap(@{x=x,y=seed},None(),None()))
  end

extern fun insert(
  t : Option(treap),
  x : int
): Option(treap)

implement insert(t,x) =
  let
    val leg = split(t,x)
  in
    case+ leg.equal of
      | Some(_) => merge3(leg)
      | None() =>
          let
            val new = new_treap(x)
          in
            merge3(@{lower=leg.lower, equal=new, greater=leg.greater})
          end
  end

extern fun erase(
  t : Option(treap),
  x : int
) : Option(treap)

implement erase(t,x) =
  let
    val leg = split(t,x)
  in
    merge(leg.lower,leg.greater)
  end

extern fun empty():Option(treap)
implement empty() = None

implement main0(argc,argv) =
  let
    fun loop(
      t : Option(treap),
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
