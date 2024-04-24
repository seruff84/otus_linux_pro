                

class NetAddr:
  def __init__(self,ip_addr) -> None:
    ip_mask = ip_addr.split('/') 
    if len(ip_mask)>1:
      self.ip_addr,self.short_mask = ip_mask
    else:
      self.ip_addr = ip_mask[0]
      
    self.bin_ip = (self.ip_to_bin(self.ip_addr))

  def mask_to_bin(self,mask):
    wk = 32 - int(mask)
    return (int('0b'+"1"*int(mask)+'0'*wk,2))

  def ip_to_bin(self,ip) -> bin:
    octets = ip.split('.')
    return (int(''.join(format(int(a),'08b') for a in octets),2))
  
  def bin_to_dot(self,addr=None):
    addr = self.bin_ip if addr is None else addr
    text_ip = format(addr,'b')
    if len(text_ip) < 32:
      text_ip = "0"*(32-len(text_ip))+text_ip
    ip_arr=[]
    for char_index in range(0,len(text_ip),8):
      ip_arr.append(str(int(text_ip[char_index:char_index+8],2)))  
    return(".".join(ip_arr))
  
  def __repr__(self) -> str:    
    return self.bin_to_dot()
  
  def __and__(self,other):
    return NetAddr(self.bin_to_dot(self.bin_ip & other.bin_ip))
  
  def __or__(self,other):
    return NetAddr(self.bin_to_dot(self.bin_ip | other.bin_ip))
  
  def __xor__(self,other):
    return NetAddr(self.bin_to_dot(self.bin_ip ^ other.bin_ip))
  
  def __invert__(self):
    self.bin_ip
    return NetAddr(self.bin_to_dot(~(self.bin_ip)))
  
 
class IpAddr(NetAddr):
  def __init__(self, ip_addr):
    super().__init__(ip_addr)
    self.bin_mask = (self.mask_to_bin(self.short_mask))
    self.bin_net = (self.bin_ip) & (self.bin_mask)
    self.mask = NetAddr(self.bin_to_dot(self.bin_mask))
    self.ip = NetAddr(self.bin_to_dot(self.bin_ip))
    self.net = NetAddr(self.bin_to_dot(self.bin_net)) 
    self.host_count = 2**(32-int(self.short_mask))-2
    self.revers_mask = NetAddr(self.bin_to_dot(self.get_revers_mask()))
    self.broadcast =  self.revers_mask | self.net
    
  def get_revers_mask(self): 
    b_string = format(self.bin_mask,'b')
    ib_string = ""
    for bit in b_string:
      if bit == "1":
        ib_string += "0"
      else:
        ib_string += "1"
    return int(ib_string,2)
  
  def increase_ip(self):
    if self.bin_ip < self.broadcast.bin_ip:
      self.bin_ip = self.bin_ip + 1
  
  def decrease_ip(self):
    if self.bin_ip > self.net.bin_ip:
      self.bin_ip = self.bin_ip - 1
    
     
 
  
x=IpAddr('192.168.0.30/18')
y=IpAddr('192.168.0.60/24')
z=NetAddr('0.0.0.255')
print(x)
print(x.host_count)
for a in range (x.host_count):
  
  x.net.increase_ip()
  print(x)
print(x.host_count)
  