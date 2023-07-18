# hexlet-terraform

Пример использования terraform для подготовки инфраструктуры в DigitalOcean и запуска приложения с помощью ansible на этой инфраструктуре

## Создание инфраструктуры для App

* Указываем секреты и другие переменные.
Например в файле secrets.auto.tfvars:

``` bash
$ cat secrets.auto.tfvars
do_token = "ваш токен от DigitalOcean"
ssh_key_name = "заранее загруженный публичный ssh ключ в DO"
regiondc = "сокращенное имя региона ДЦ DO"
vpc_private_net = "Приватная сеть"
admin_net = ["сети админ доступа"]
```

* Создать план, проверить конфигурацию:

```
terraform plan
```

* Применить конфигурацию (развернуть инфраструктуру):
``` 
terraform apply
```

## Запуск приложения с помощью ansible (пример flask hello world):
В качестве примера будет запущен Flask с Hello World из app/app.py, соответственно таска в playbook подойдет для запуска приложения на Flask. Для запуска определенного приложения необходимо будет заменить соответствующую таску. Также в качестве примера устанавливается агент DataDog с настройкой для проверки HTTP этого приложения на порту 5000.

* Создаем файл ansible/inventory с указанием ранее созданных дроплетов (ВМ).
* Создаем файл ansible/.vault.yml и заполняем по примеру:

``` bash
$ cat ansible/.vault.yml
app_path: 'путь до приложения'
app_dir: 'рабочая директория'
app_env: 'env'

dd_api_key: 'DataDog API Key'
ansible_user: 'Используемый пользователь на ВМ'
```

* Устанавливаем роли Ansible

``` bash
$ ansible-galaxy install -r requirements.yml
```

* Добавляем приватный ключ, если он не был добавлен ранее.
* Запускаем плейбук:
``` bash
$ ansible-playbook -i inventory playbook.yaml
```
Если <i>.vault.yml</i> был зашифрован паролем, то используем ключ --ask-value-pass для ввода пароля из терминала.

После этих действий можно открыть страницу с hello world по ip балансировщика.