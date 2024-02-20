def add(x, y, p = False):
  if p:
    print(type(x))
  return x + y


def check_python_type(x):
  print(type(x))
  return x


def add_with_print(x, y):
  print(x, 'is of the python type ', type(x))
  return x + y
