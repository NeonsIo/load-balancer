# Load balancer

This is docker build for neons load balancer.
It is based on haproxy.

# Usage

    1. Create directory with files:
    
        1.1 load-balancer/haproxy/haproxy.cfg
        
            global
              log 127.0.0.1 local0
              log 127.0.0.1 local1 notice
              chroot /var/lib/haproxy
              user haproxy
              group haproxy
            
            defaults
              log global
              mode http
              option httplog
              option dontlognull
            
            frontend localnodes
              bind *:80
              bind *:443 ssl crt /etc/ssl/default/default.pem #ssl certificate file
              redirect scheme https if !{ ssl_fc }
              mode http
              default_backend nodes
            
            backend nodes
              mode http
              balance roundrobin
              option forwardfor
              option httpchk GET /health # healthcheck endpoint
              server web01 10.0.0.21:80 # <- IP of first node
              server web02 10.0.0.22:80 # <- IP of second node
              server web02 10.0.0.23:80 # <- IP of third node
              http-request set-header X-Forwarded-Port %[dst_port]
              http-request add-header X-Forwarded-Proto https if { ssl_fc }
        
        1.2 load-balancer/rsyslog//haproxy.conf
            
            $ModLoad imudp
            $UDPServerAddress 127.0.0.1
            $UDPServerRun 514
            
            local1.* -/var/log/haproxy_1.log
            & ~

        1.3 load-balancer/ssl/default.pem
        
            -----BEGIN CERTIFICATE-----
            MIICUTCCAboCCQCAJ1GNurFoMTANBgkqhkiG9w0BAQsFADBtMQswCQYDVQQGEwJQ
            TDETMBEGA1UECAwKU29tZS1TdGF0ZTEQMA4GA1UEBwwHV3JvY2xhdzERMA8GA1UE
            CgwITmVvbnMuSW8xETAPBgNVBAsMCE5lb25zLklvMREwDwYDVQQDDAhuZW9uc19p
            bzAeFw0xNzA2MjcxOTA3MjBaFw0xODA2MjcxOTA3MjBaMG0xCzAJBgNVBAYTAlBM
            MRMwEQYDVQQIDApTb21lLVN0YXRlMRAwDgYDVQQHDAdXcm9jbGF3MREwDwYDVQQK
            DAhOZW9ucy5JbzERMA8GA1UECwwITmVvbnMuSW8xETAPBgNVBAMMCG5lb25zX2lv
            MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC8JFRwEjZqV7DG8PrYYgVLEY0v
            hSByLFhAr6NYdMbveue7ahQk+e8zgCO4l/XkuBAdFn+j8zhC7m0UbE1+3RzMggmC
            sJXqL/N24n1fksSfDTk0Wg7qyZB3x0vd/N4rrsjcDC7XKt7LsYyr3Rnl6EfSQh/7
            E/ShcoiOTTlGCuKOxQIDAQABMA0GCSqGSIb3DQEBCwUAA4GBAJqzUExdCy2XfSqL
            pe8rLbQxOSeksGUj3qX45/2ONtZxvB/q1C6je7R252T4JJvfN/66naPWBm4QWg7i
            RQEIXrzr0DQI3zX+MoZJa5rZToPhOi5HCyytmPPwwcO6KVknz3Yd58wpLbwavjqp
            XIaTSt8gk477H+11yXzIw3e9/rTt
            -----END CERTIFICATE-----
            -----BEGIN RSA PRIVATE KEY-----
            MIICXQIBAAKBgQC8JFRwEjZqV7DG8PrYYgVLEY0vhSByLFhAr6NYdMbveue7ahQk
            +e8zgCO4l/XkuBAdFn+j8zhC7m0UbE1+3RzMggmCsJXqL/N24n1fksSfDTk0Wg7q
            yZB3x0vd/N4rrsjcDC7XKt7LsYyr3Rnl6EfSQh/7E/ShcoiOTTlGCuKOxQIDAQAB
            AoGBAIC4QmTisQQUtseFe7mrZn+zpGrMpCQ5HrAy+oi8bJbP+deJffrGXNdZZhcX
            MI6pN60PBYkAEJAKW+rLJkITuW0smIRKdzajxPVbxlT2FlNRifMIe6OvJhdhgTL9
            bIwGQdXP0rL2BZdGUZLjLA02IroeTqq9Kh6WHsquRip+t8ABAkEA7V9jIRVEd5d7
            MG7qYOS2g6pN3hqBxJWoVojROxwleDZUx5RxdBpIDj0rxJZM6yHnguNSfp3jfHNU
            lkw0Kp4IAQJBAMrn8KhXaE3ELJBt++apmoBexDayAipAk6Fy4ACwpdskZJFkZ4OV
            xPFsG/WUDM8+mmjExu+LCr2QH1HF0ZgWZsUCQHG2J0O673Cm5YGfMLI3/mL2m5TR
            d+bXlqvVoP3DDwQWauis6Oioimofza7AHZrqRACEq4kyU77TdOsHGFpuGAECQQCX
            93bq3ewkslSeJ4GOlGA+3LsgK9orQwpO1PaoDaVqp6saqZRNnRJPrqSSHTwqy7xh
            018bcYutxg9u8zWzLrPxAkBeTeXEP1te91j+jd4aGNPH5QBpszE40jadOYy5+IVB
            J0GUDHMX6VRhTkGoAZI1WDg8RllyQF9bby0eIIyJWpZ4
            -----END RSA PRIVATE KEY-----

    2. Create docker-compose.yml file
    
          lb:
            container_name: lb
            image: neons/load-balancer:latest
            ports:
              - 80:80
              - 443:443
            depends_on:
              - node-1 #service name from haproxy.cfg
              - node-2 #service name from haproxy.cfg
            volumes:
              - ./load-balancer/haproxy:/usr/local/etc/haproxy
              - ./load-balancer/rsyslog:/etc/rsyslog.d
              - ./load-balancer/ssl:/etc/ssl/default
            
     3. Run: docker-compose up -d
  
  # License
  
  License can be found [here](https://github.com/NeonsIo/load-balancer/blob/master/LICENSE).
