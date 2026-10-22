# Rojo vs. azul: tu tienda protegida con WAF

Laboratorio pendiente de la clase 12 · Esumer · Cloud Computing, Redes y Ciberseguridad.
**Solo se prueba contra TU propia tienda, en TU propia cuenta.**

```
rojo-vs-azul-waf/
└── terraform/
    ├── main.tf          S3 privado + CloudFront (HTTPS) + AWS WAF
    ├── index.html       la página de tu tienda (pon tu nombre)
    └── bloqueo.tfvars   la lista negra de IPs (paso del equipo azul)
```

## Antes de empezar (una sola vez)

IAM → Usuarios → `terraform-lab` → Agregar permisos → `AWSWAFFullAccess`
(S3 y CloudFront ya los tiene de clases pasadas).

## Paso 0 · La tienda con escudo

En la terminal de VS Code, **dentro de la carpeta `terraform`**:

```powershell
cd terraform
terraform init
terraform apply      # Plan: 8 to add → yes · CloudFront tarda 3–5 minutos
```

Abre `tu_web_https`: tu tienda con 🛡️. El WAF arranca en modo **observar** (cuenta, no bloquea).

## Equipo rojo · la ráfaga contra tu propia tienda

```powershell
$W = "https://dxxxxxxxxxx.cloudfront.net"   # ⚠ reemplaza por TU tu_web_https
curl.exe -s -o NUL -w "%{http_code}`n" "$W/?buscar=camiseta"
1..150 | ForEach-Object { curl.exe -s -o NUL -w "%{http_code} " "$W/" }
```

Todas dan 200: el WAF solo observa. Míralo en la consola:
**WAF y Shield → Paquetes de protección (ACL web) → escudo-tienda → Ver el panel, los registros y las solicitudes de muestra**
→ la regla `limite-por-ip` aparece en COUNT (tarda 1–3 min).

## Equipo azul · activa el escudo

```powershell
terraform apply -var="modo=bloquear"
1..150 | ForEach-Object { curl.exe -s -o NUL -w "%{http_code} " "$W/" }
```

Después de ~100 peticiones empiezan los **403** (puede tardar hasta 1 minuto en reaccionar).

**Lista negra:** mira tu IP pública y ponla en `bloqueo.tfvars` (con `/32`):

```powershell
curl.exe -s https://checkip.amazonaws.com
terraform apply -var-file="bloqueo.tfvars"
```

Abre tu tienda: **403 Request blocked** → te bloqueaste a ti mismo 😄
La lista está en **WAF y Shield → Conjuntos de IP → lista-negra**.

## Al terminar (¡importante! el WAF cobra por hora)

```powershell
terraform destroy    # escribe yes · Resources: 8 destroyed
```
