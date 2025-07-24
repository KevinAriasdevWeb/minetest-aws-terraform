# Minetest Server en AWS con Terraform y Auto Scaling

Este proyecto despliega un servidor de **Minetest** en AWS usando **Terraform** con un **Auto Scaling Group**, manteniéndose dentro del Free Tier.

---

## 📦 Contenido

- EC2 t2.micro (Ubuntu 22.04)
- Launch Template para instalar Minetest automáticamente
- Auto Scaling Group (1 instancia fija)
- Security Group con puertos 22 (SSH) y 30000 (Minetest)
- Salida con IP pública para conectarte desde tu cliente

---

## 🚀 Requisitos

- Cuenta de AWS dentro del Free Tier
- AWS CLI configurado (`aws configure`)
- Terraform instalado
- Una key pair local (ej: `~/.ssh/minetest-key`)

---

## ⚙️ Variables principales

Edita el archivo `terraform.tfvars`:

```
key_name        = "minetest-key"
public_key_path = "~/.ssh/minetest-key.pub"
```

---

## 🧪 Pasos para desplegar

```bash
terraform init
terraform plan
terraform apply
```

Copiarás la IP pública desde la salida y podrás conectarte:

```bash
ssh -i ~/.ssh/minetest-key ubuntu@<IP>
```

Luego entra en Minetest, selecciona "Multiplayer" y pon la IP + puerto `30000`.

---

## 🧹 Para destruir todo

```bash
terraform destroy
```

---

## 📝 Notas

- El Auto Scaling Group mantiene **solo una instancia** (`max_size = 1`)
- El script `user_data.sh` instala y lanza el servidor de Minetest automáticamente
- Está optimizado para que no te salgas del **AWS Free Tier**

---

## 🧠 Créditos

Creado por Kevin
