#!/usr/bin/env bash
set -e

echo "Testando URLs locais da VM..."

test_url() {
    name="$1"
    url="$2"

    status="$(curl -o /dev/null -s -w "%{http_code}" "$url" || true)"
    if [ "$status" = "200" ] || [ "$status" = "302" ] || [ "$status" = "403" ]; then
        echo "OK   $name -> $url ($status)"
    else
        echo "FALHA $name -> $url ($status)"
        return 1
    fi
}

test_url "Jenkins" "http://localhost:8080"
test_url "Homologacao" "http://localhost:5001/login"
test_url "Producao" "http://localhost:5000/login"
