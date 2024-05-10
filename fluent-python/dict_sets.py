## custom dict class to convert 
class StrKeyDict0(dict):  

    def __missing__(self, key):
        if isinstance(key, str):  
            raise KeyError(key)
        return self[str(key)]  

    def get(self, key, default=None):
        try:
            return self[key]  
        except KeyError:
            return default  

    def __contains__(self, key):
        return key in self.keys() or str(key) in self.keys()
    
def main():
    # custom dict will accept either a string value or int value as a keyß
    d1 = StrKeyDict0([('2', 'two'), ('4', 'four')])
    print('\nCustom Dictionary:\n')
    print(d1)
    print(f"d1['2'] returns: {d1['2']}")
    print(f"d1[2] also returns: {d1[2]}")
    print()
    # standard dictionary:
    print('\nStandard dictionary:\n')
    d2 = dict([('2', 'two'), ('4', 'four')])
    print(d2)
    print(f"d2['2'] returns: {d2['2']}")
    print(f"d2[2] results in a KeyError\n")

if __name__ == "__main__":
    main()