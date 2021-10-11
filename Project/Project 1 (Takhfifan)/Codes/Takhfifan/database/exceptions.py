class NoConnection(Exception):
    
    def __init__(self):
        self.message = 'Not connected to dbms.'
    
    def __str__(self):
        return self.message