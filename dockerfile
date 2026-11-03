
FROM julia:1.10

WORKDIR /app

RUN julia -e 'using Pkg; Pkg.add("Genie")'

COPY . .

EXPOSE 8000

CMD ["julia", "main/codes/page.jl"]
