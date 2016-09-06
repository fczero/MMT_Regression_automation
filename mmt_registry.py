import _winreg
import errno
import os

def Get_Version_From_Registry():
    ''' returns string of MMT version from the registry 
    '''
    retVal = ""
    proc_arch = os.environ['PROCESSOR_ARCHITECTURE'].lower()
    proc_arch64 = os.environ['PROCESSOR_ARCHITEW6432'].lower()
    if proc_arch == 'x86' and not proc_arch64:
        arch_keys = {0}
    elif proc_arch == 'x86' or proc_arch == 'amd64':
        arch_keys = {_winreg.KEY_WOW64_32KEY, _winreg.KEY_WOW64_64KEY}
    else:
        raise Exception("Unhandled arch: %s" % proc_arch)
    for arch_key in arch_keys:
        oReg = _winreg.ConnectRegistry(None, _winreg.HKEY_LOCAL_MACHINE)
        key = _winreg.OpenKey(oReg, r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",0,_winreg.KEY_READ | arch_key)
        try:
            key = _winreg.OpenKey(key, r"MMT",0,_winreg.KEY_READ | arch_key)
            ver = []
            ver.append(str(_winreg.QueryValueEx(key, "VersionMajor")[0]))
            ver.append(str(_winreg.QueryValueEx(key, "VersionMinor")[0]))
            ver.append(str(_winreg.QueryValueEx(key, "VersionMicro")[0]))
            ver.append(str(_winreg.QueryValueEx(key, "VersionBuild")[0]))
            retVal = '.'.join(ver)
        except OSError as e:
            if e.errno == errno.ENOENT:
                # No MMT entry in this key
                pass
        finally:
            key.Close()
    return retVal

if __name__ == "__main__":
    Get_Registry_Key()
