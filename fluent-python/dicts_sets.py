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
    d1 = StrKeyDict0([('2', 'two'), ('4', 'four')])
    d1['2']
    print(d1)

if __name__ == "__main__":
    main()