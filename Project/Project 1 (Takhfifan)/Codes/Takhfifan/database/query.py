class QueryResult():
    def __init__(self, **fields):
        self.__dict__.update(fields)
    
    def values(self):
        return self.__dict__.values()
    
    def __str__(self):
        ret = 'QueryResult <'
        first = True
        for key, value in self.__dict__.items():
            if not first:
                ret += ', '
            ret += '{}: {}'.format(key, value)
            first = False
        ret += '>'
        return ret

class QueryResults():
    
    def __init__(self, result=None):
        self.results = []
        if result is not None:
            if type(result) is QueryResult:
                self.results.append(result)
            else:
                assert type(result) is list
                
                for res in result:
                    assert type(res) is QueryResult
                    
                    self.results.append(res)
    
    def add(self, result):
        assert type(result) is QueryResult
        
        self.results.append(result)
    
    def all(self):
        return self.results
    
    def one(self):
        assert len(self.results) == 1
        
        return self.results[0]
    
    def values(self):
        lst = []
        for result in self.results:
            lst.append(result.values())
        
        return lst