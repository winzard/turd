class A:
    strategy = MAStategy()

class B(A):
    a = 2


assert A.a == 1
print(A.a)