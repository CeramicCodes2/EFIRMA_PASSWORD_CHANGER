from argparse import ArgumentParser
def arguments():
    ag = ArgumentParser()
    ag.add_argument('fileout',help='file output')
    args = ag.parse_args()
    
    return args.fileout
def main():
    passin = input('Ingrese su contraseña:')
    output = arguments()
    
    with open(f'{output}','wb') as wb:
        wb.write(passin.encode('utf-16le'))

if __name__ == '__main__': main()

