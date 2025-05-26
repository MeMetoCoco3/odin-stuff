package main

import "core:fmt"


fib :: proc(n: int)-> int{
  // Switch without argument is like a ifelse
  switch {
    case n<1:
      return 0
    case n==1:
      return 1
  }
  return fib(n-1) + fib(n-2)
}



main :: proc(){
  res := fib(10)
  fmt.println(res)
}
