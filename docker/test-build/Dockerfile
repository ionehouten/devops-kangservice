# This Dockerfile only for Github Action test
FROM nginx:stable-alpine

RUN echo '<!DOCTYPE html>\
<html>\
<head>\
    <title>Pipeline Test Success</title>\
    <style>\
        body { font-family: sans-serif; text-align: center; margin-top: 100px; background: #f4f6f9; color: #333; }\
        .card { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: inline-block; }\
        h1 { color: #2ecc71; }\
    </style>\
</head>\
<body>\
    <div class="card">\
        <h1>🚀 Build Successful!</h1>\
        <p>The GitHub Actions Docker pipeline works perfectly.</p>\
        <small>Image Base: nginx:stable-alpine</small>\
    </div>\
</body>\
</html>' > /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]