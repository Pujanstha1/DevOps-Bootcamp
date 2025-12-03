# Data Persistence in Containers
### 1. Pull a NGINX or httpd container.
- First we start by pulling the nginx image from `hub.docker.com`
    ![alt text](images/1.pull_docker_image.png)
- We can see the image in Docker Desktop > Images
![alt text](images/2.image_in_docker.png)

- Create the docker container from the image.
`docker run --name mynginx -p 80:80 -d nginx`
![alt text](images/3.create_container.png)

- The container has been created and can be viewed in Container section.
![alt text](images/4.container_created.png)
    ### 2. Browse the default page in http://localhost 
    When running the `http://localhost`, we can see:
    ![alt text](images/5.localhost.png)

- We can check the container files in:

    `docker exec -it mynginx bash`

    `ls -l /usr/share/nginx/html/`

    ![alt text](images/6.nginx_html_file.png)

    ### 3. Alter the default content

    Now inside the container, we will make some changes to the default web contents.
- `docker exec -it mynginx bash`
- `echo '<h1>Hello World!! This is me PUJAN!!!</h1>' > /usr/share/nginx/html/index.html`
- `cat index.html`
![alt text](images/7.%20modify_html_content.png)

- Now when we check the `localhost` again, we see `Hello World!! This is me PUJAN!!!`:
![alt text](images/8.changed_html.png)

    ### 4. Stop and start the container again and check if the content persists.
- Next, we stop and start our container again.
![alt text](images/9.start_and_stop_nginx.png)
- Even after the container stopped and started, we can see that the content has persisted.
![alt text](images/8.changed_html.png)

    ### 5. Remove the container and spin it again and check the persistence again.
- Stop the container `docker stop 1467328a11c8`
- Remove the container `docker rm 1467328a11c8`
- Spin another container `docker run --name mynginx -p 80:80 -d nginx`
![alt text](images/10.remove_and_spin_container_again.png)
- Run the localhost webpage again `http://localhost`

    ![alt text](images/5.localhost.png)

- Here, we can see that the custom content is gone because we modified data inside the container, not in a persistent volume.

    ### 6. If content does not persist, try different ways to make it persistence.

- We will run nginx with a bind mount.

    ```
    docker run --name mynginx -p 80:80 -d \
    -v $(pwd)/nginx-data:/usr/share/nginx/html \
    nginx
    ```
    ![alt text](images/11.bind_mount.png)
- Here, we will see `Persistent Content` in `localhost` page.

    ![alt text](images/12.persistent_data.png)

    ###  7. Remove the container and spin it again and check the persistence again.

    We will restart the container

    `docker stop mynginx`

    `docker start mynginx`

- Again, while checking, our content persists

    ![alt text](images/12.persistent_data.png)

- Next, we will remove the container and re-run new container with the same bind mount

    ```
    docker rm -f mynginx

    docker run --name mynginx -p 80:80 -d \
    -v $(pwd)/nginx-data:/usr/share/nginx/html \
    nginx
    ```
- The content still persists because the file are stored in our host folder.

    ![alt text](images/12.persistent_data.png)


    ## (METHOD 2): We can achiece the same result with **Docker Volumes** as well
- First, we will create a volume named `nginx-volume`
- Secondly, we will run container using the volume
`docker volume create nginx-volume`
    ```
    docker run --name nginx -p 80:80 -d \
    -v nginx-volume:/usr/share/nginx/html \
    nginx
    ```
    ![alt text](images/13.nginx_container_with_volume.png)

- We execute `mynginx` container in `interactive` mode with `bash shell` 
- We then enter the content in `/usr/share/nginx/html/index.html`
    ```
    docker exec -it mynginx bash
    echo "Content from Docker Volume" > 
    /usr/share/nginx/html/index.html
    exit
    ```
    ![alt text](images/14.enter-data_in_volume.png)

- We stop/remove the container and re-run a new container with same volue
    ```
    docker stop mynginx
    docker rm mynginx
    ```
    ```
    docker run --name mynginx -p 80:80 -d \
  -v nginx-volume:/usr/share/nginx/html \
  nginx
    ```
    ![alt text](images/15.re-run_with_new_container.png)

    ![alt text](images/16.new_output.png)
