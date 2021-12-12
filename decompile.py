import argparse
import os 
from pathlib import Path
import subprocess
import shutil

def main():
    pass


def ArgumentParser():
    parser = argparse.ArgumentParser(description='decompile apk tools',  formatter_class=argparse.MetavarTypeHelpFormatter)
    parser.add_argument('-s', '--source',  type=str, required=True, help='decompile target apk file path.')
    parser.add_argument('-o', '--output', type=str,help='decompile outout folder path. ')
    return parser.parse_args()

def PrepareEnvironment(args):
    apkname = Path(args.source).stem #only filename no extension
    if args.output is None:   
        args.output  = os.path.join(os.path.dirname(args.source), f"decompile-{apkname}")
    
    if Path(args.output).is_dir():
        shutil.rmtree(args.output)

def  Decompile(apkpath, outpath):
    subprocess.run(['tools\\apktool.bat', 'd', apkpath, '-o', outpath])

    # 判断目录是否存在，不存在证明执行apktool命令出现异常
    if not Path(outpath).is_dir():
        raise Exception("execude apktool decompile occur error.")

    # 判断目录是否为空，为空证明执行apktool命令出现异常
    if not any(Path(outpath).iterdir()):
        raise Exception("execude apktool decompile occur error.")


if __name__ == '__main__':

    args = ArgumentParser()
    print(args)

    PrepareEnvironment(args)
    Decompile(args.source, args.output)
    
    main()
    