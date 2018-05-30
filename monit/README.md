Just do it!

```
bash <(curl -s http://saturn.5fpro.com/monit/hi.sh)
```

For standalone setup:

```
# install monit
bash <(curl -s http://saturn.5fpro.com/monit/install.sh)

# nginx config
bash <(curl -s http://saturn.5fpro.com/monit/nginx.sh)

# sidekiq config
bash <(curl -s http://saturn.5fpro.com/monit/sidekiq.sh)

# unicorn config
bash <(curl -s http://saturn.5fpro.com/monit/unicorn.sh)

# puma config
bash <(curl -s http://saturn.5fpro.com/monit/puma.sh)

# lita config
bash <(curl -s http://saturn.5fpro.com/monit/lita.sh)
```
