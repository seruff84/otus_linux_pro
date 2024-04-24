import ipaddress
import pandas as pd


def find_common_subnet(ip1, ip2):
    ip1_address = ipaddress.ip_address(ip1)
    ip2_address = ipaddress.ip_address(ip2)
    ip1_int = int(ip1_address)
    ip2_int = int(ip2_address)
    common_subnet_int = ip1_int & ip2_int
    prefix_length = 0
    while common_subnet_int:
      prefix_length += 1
      common_subnet_int >>= 1
      try:
        common_subnet = ipaddress.IPv4Network((ip1, prefix_length))
      except:
        continue
      if ip2_address not in common_subnet:
        return common_subnet


def find_intermediate_networks(network1, network2):
  network1_first_address = int(network1.broadcast_address)
  network1_last_address = int(network1.network_address)
  network2_first_address = int(network2.broadcast_address)
  network2_last_address = int(network2.network_address)
  start_address = min(network1_first_address, network2_first_address) + 1
  end_address = max(network1_last_address, network2_last_address)
  intermediate_networks = find_common_subnet(start_address,end_address)
  return intermediate_networks



data = pd.read_csv('net.csv',delimiter=';')
df = pd.DataFrame(data)
net_list = df['net_addr'].tolist()
nets=[]
for item in net_list:
  net = ipaddress.ip_network(item)
  nets.append(net)
net1 = None
net2 = None
for net in nets:
  net2 = net
  if net1 == None:
    net1 = net
    continue
  subnet = find_intermediate_networks(net1, net2)
  if subnet is not None:
    df.loc[ len(df.index )] = ['None',str(subnet),'Free']
  net1 = net2
df.drop_duplicates(subset=['net_addr'])
df['hosts'] = None
df = df.reset_index() 
for index,row in df.iterrows():
  df.at[index,'net_addr'] = ipaddress.IPv4Network(row['net_addr'])
  host_count = int(ipaddress.IPv4Network(row['net_addr']).num_addresses -2)
  Hostmax = ipaddress.IPv4Network(row['net_addr']).broadcast_address -1
  Hostmin = ipaddress.IPv4Network(row['net_addr']).network_address +1
  Broadcast = ipaddress.IPv4Network(row['net_addr']).broadcast_address
  df.at[index,'hosts'] = host_count
  df.at[index,'Hostmin'] = Hostmin
  df.at[index,'Hostmax'] = Hostmax
  df.at[index,'Broadcast'] = Broadcast
  df.sort_values(by='net_name')
print(f"DataFrame:\n{df}\n")
  
  
