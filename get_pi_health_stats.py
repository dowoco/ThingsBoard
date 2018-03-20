import psutil,socket,fcntl,struct,os,time
import requests
from subprocess import check_output
from re import findall

#=================================================
#------- Declaration: Local Variables
#=================================================
accessToken = "xxxxxxxxxxxxxxxxxxx"
Turl = "http://192.168.x.x:8080/api/v1/" + accessToken + "/telemetry"
Aurl = "http://192.168.x.x:8080/api/v1/" + accessToken + "/attributes"
networkAdaptor = "eth0"

#=================================================
#------- Functions
#=================================================

def get_uptime():
    uptime = float(os.popen("awk '{print $1}' /proc/uptime").readline())
    return str(time.strftime("%d-day(s) %H:%M:%S", time.gmtime(uptime)))

def get_temp():
    temp = check_output(["vcgencmd","measure_temp"]).decode("UTF-8")
    return(findall("\d+\.\d+",temp)[0])

def get_ip_address(ifname='eth0'):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])

def getMAC(interface='eth0'):
  # Return the MAC address of the specified interface
  try:
    str = open('/sys/class/net/%s/address' %interface).read()
  except:
    str = "00:00:00:00:00:00"
  return str[0:17]

def get_human_readable_size(num):
    exp_str = [ (0, 'B'), (10, 'KB'),(20, 'MB'),(30, 'GB'),(40, 'TB'), (50, 'PB'),]
    i = 0
    while i+1 < len(exp_str) and num >= (2 ** exp_str[i+1][0]):
        i += 1
        rounded_val = round(float(num) / 2 ** exp_str[i][0], 2)
    return '%s %s' % (int(rounded_val), exp_str[i][1])


#=================================================
#------ Main Code
#=================================================
debugOn=False
if debugOn:
    print(get_uptime())
    print(getMAC(networkAdaptor))
    print(get_ip_address(networkAdaptor))
    print(socket.gethostname())
    print(get_temp())
    print (psutil.cpu_percent(interval=1))
    print (psutil.virtual_memory().percent)
    print (psutil.disk_usage('/').percent)
    print (get_human_readable_size(psutil.virtual_memory().total))

while True:
    data = "{'cpu_percent':'" + str(psutil.cpu_percent(interval=1)) +  \
            "','memory_usage_percent':'" + str(psutil.virtual_memory().percent) + \
            "','cpu_temp':'" + str(get_temp()) + \
            "','storage_usage_percent':'" + str(psutil.disk_usage('/').percent) + "'}"

    s = requests.Session()
    s.headers.update({'Content-type':'application/json'})
    try:
        r = s.post(Turl,data)
    except:
        print("unable to send")

    data = "{'hostname':'" + socket.gethostname() +  \
           "','mac':'" + getMAC(networkAdaptor) + \
           "','adaptor':'" + networkAdaptor + \
           "','uptime':'" + get_uptime() + \
           "','total_memory':'" + get_human_readable_size(psutil.virtual_memory().total) + \
           "','ipaddress':'" + get_ip_address(networkAdaptor) + "'}"

    s = requests.Session()
    s.headers.update({'Content-type':'application/json'})
    try:
        r = s.post(Aurl,data)
    except:
        print("unable to send")

    time.sleep(5)

