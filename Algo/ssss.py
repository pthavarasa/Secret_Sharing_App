from random import randint
from sympy import *
from sympy.solvers import solve
from sympy.core.expr import *

S=1234

x=symbols('x', integer=True)

def getPolnyome(S,n,k):
	polynome=S
	for i in range(1,k):
		polynome+=randint(50,250)*x**i
	return polynome

def getPoint(polynome,v):
	return polynome.subs(x,v)

def getPoints(polynome,n):
	lst_point=[]
	p=()
	for i in range(0,n):
		k=randint(1,255)
		p=k,getPoint(polynome,k)
		lst_point.append(p)
	return lst_point

def getSecret(lst_key,k):
	t=[]
	polynome=0
	for i in range(0,k):
		l=1
		for j in range(0,k):
			if i!=j:
				l*=((x-lst_key[j][0])/(lst_key[i][0]-lst_key[j][0]))
		t.append(l)
	for i in range(0,k):
		polynome+=lst_key[i][1]*t[i]
	return simplify(polynome).args[0]

k=3
n=12

polynome=getPolnyome(S,n,k)
print(polynome)
lst=getPoints(polynome,n)
print(lst)
secret=getSecret(lst,k)
print(secret)