# EFIRMA_PASSWORD_CHANGER
# SAT_PASSWORD_CHANGER
Herramienta para cambiar contraseñas de claves de cifrado de la efirma
# Como funciona ?
basicamente las contraseñas del sat son claves RSA estas claves se cifran usando el formato DER el cual puede ser modificado por la herramienta
`openssl` para cambiar la contrase;a de cifrado, pero obviamente es necesario recordar la contrase;a original para poder hacer el cambio
## en profundidad
la forma de cambiar estos datos es primero convirtiendo la clave e firma a un formato sin cifrar (PEM) para despues volver a convertirla a un formato cifrado (DER)
este cambio se hace respetando los criptosistemas que usa el SAT para el descifrado es decir `DES-EDE3-CBC` (si siguen usando DES3 en pleno 2025)
el principal problema con usar `openssl` sin parametros sumamente especificos es que estos agregaban campos ASN adicionales
en otras palabras etiquetas adicionales que los servicios del SAT no aceptaban al reconocer como se muestra en el siguiente ejemplo:
```
comando para obtener este resultado:
openssl asn1parse -in "ruta_clave_privada.key" -inform DER 2>/dev/null

ORIGINAL:

    0:d=0  hl=4 l=1308 cons: SEQUENCE
    4:d=1  hl=2 l=  78 cons: SEQUENCE
    6:d=2  hl=2 l=   9 prim: OBJECT            :PBES2
   17:d=2  hl=2 l=  65 cons: SEQUENCE
   19:d=3  hl=2 l=  41 cons: SEQUENCE
   21:d=4  hl=2 l=   9 prim: OBJECT            :PBKDF2
   32:d=4  hl=2 l=  28 cons: SEQUENCE
   34:d=5  hl=2 l=   8 prim: OCTET STRING      [HEX DUMP]:CE1E801D67212D97
   44:d=5  hl=2 l=   2 prim: INTEGER           :0800
   48:d=5  hl=2 l=  12 cons: SEQUENCE
   50:d=6  hl=2 l=   8 prim: OBJECT            :hmacWithSHA256
   60:d=6  hl=2 l=   0 prim: NULL
   62:d=3  hl=2 l=  20 cons: SEQUENCE
   64:d=4  hl=2 l=   8 prim: OBJECT            :des-ede3-cbc
   74:d=4  hl=2 l=   8 prim: OCTET STRING      [HEX DUMP]:77086652E8EDC9BC

GENERADO POR SCRIPT:
    0:d=0  hl=4 l=1308 cons: SEQUENCE
    4:d=1  hl=2 l=  78 cons: SEQUENCE
    6:d=2  hl=2 l=   9 prim: OBJECT            :PBES2
   17:d=2  hl=2 l=  65 cons: SEQUENCE
   19:d=3  hl=2 l=  41 cons: SEQUENCE
   21:d=4  hl=2 l=   9 prim: OBJECT            :PBKDF2
   32:d=4  hl=2 l=  28 cons: SEQUENCE
   34:d=5  hl=2 l=   8 prim: OCTET STRING      [HEX DUMP]:EFF280DE92D25997
   44:d=5  hl=2 l=   2 prim: INTEGER           :0800
   48:d=5  hl=2 l=  12 cons: SEQUENCE
   50:d=6  hl=2 l=   8 prim: OBJECT            :hmacWithSHA256 <--- AQUI SE ESPECIFICABA QUE SE USE HMAC CON SHA256 LO CUAL ES MAS SEGURO

   60:d=6  hl=2 l=   0 prim: NULL
   62:d=3  hl=2 l=  20 cons: SEQUENCE
   64:d=4  hl=2 l=   8 prim: OBJECT            :des-ede3-cbc
   74:d=4  hl=2 l=   8 prim: OCTET STRING      [HEX DUMP]:050FC51ABD1EF9B0
```

como tal `openssl` utiliza de forma tipica el algortmo `hmacsha256` que a grandes razgos funciona para hacer mas resistente la clave frente a ataques de fuerza bruta, que funciona gracias a `pbkdf2`, como tal las  las herramientas del sat que usan `openssl 1.1` esto quiere decir que no usan este enfoque mas moderno y como tal optan por usar `HMAC O SHA-1`  que `openssl 1.1` no especifica en el encabezado del archivo DER es decir es implicito, a esta version antigua de archivos DER aplicaban el estandar `PKCS#5 V2.0` (nada recomendable en la actualidad pero es lo que tienen)

# Por que crear esta herramienta

el por que es simple, muchas veces puede que cuando nos pidan colocar una contraseña para nuestra E-FIRMA accidentalmente coloquemos caracteres especiales como la `ñ` si algun usuario ha sido tan desafortunado como para que le ocurra esto, alegrese, este script le podra salvar la vida de sumergirse en un doloroso proceso burocratico.

el problema con los sistemas del SAT es que ellos utilizan la codificacion `utf16le` el cual interpreta mal caracteres como nuestra querida `ñ` 

en esos casos es recomendable usar el script `unsopportablePassword.py` para escribir en un archivo la contraseña en el formato de codificacion original con el cual se guardo o se creo la contraseña de cifrado (vamos a palabras simples solo escribimos en un archivo los bits ordenados de forma correcta de nuestra contraseña que el sistema del sat recordo) 

despues de eso es solo necesario pasar este archivo al script o programa `PasswordChanger.py` de la siguiente forma:

```bash
PasswordChanger.py --password-file=password.txt
```
y bingo el script se encargara de cambiar la contraseña.





