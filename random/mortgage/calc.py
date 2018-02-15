#!/usr/bin/env python3

import numpy
import sys
# calculate the monthly payment of mortgage, plus what if we sell at %n year

def month_pay(total, r, n):
    return total * (r * numpy.float_power(1 + r, n))/(numpy.float_power(1 + r, n) -1 )


def total_pay_if_sell_at_n(month_pay, total_principal, r, n):
    n = n * 12
    for i in xrange(0, n):
        interest = total_principal * r
        paid_principal = month_pay - interest
        total_principal -= paid_principal
    return total_principal + month_pay * n




if __name__ == "__main__":

    if len(sys.argv) != 4:
        print("usage: calc.py total interest n-year")
        sys.exit(1)
    total = float(sys.argv[1])
    r = float(sys.argv[2]) / 12
    n = int(sys.argv[3]) * 12

    month = month_pay(total, r, n)
    print("monthly payment = ", month)

    for n in [1,2,3,4,5]:
        print("sell at %d year = %f, pay =%f" % (n, total_pay_if_sell_at_n(month, total, r, n), month * n * 12))



