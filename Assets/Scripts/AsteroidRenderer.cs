using UnityEngine;
using System.Collections.Generic;
using System.Linq;

public class Asteroid
{
    public Vector3 position, scale, velocity, angularVelocity;
    public Quaternion rotation;

    public Matrix4x4 Matrix
    {
        get {
            return Matrix4x4.TRS(position, rotation, scale);
        }
    }

    public Asteroid(Vector3 position)
    {
        this.position = position;

        rotation = Random.rotation;
        scale = Vector3.one * Random.Range(0.05f, 0.7f);
        velocity = Random.insideUnitSphere * Random.Range(0.05f, 0.3f);
        angularVelocity = Random.insideUnitSphere * Random.Range(20, 100);
    }
}

[ExecuteInEditMode]
public class AsteroidRenderer : MonoBehaviour
{
    public Mesh mesh;
    public Material material;

    [Range(1, 1023)]
    public int maximumAsteroids = 1000;

    public float radius = 50f;

    private List<Asteroid> asteroids = new List<Asteroid>();

    private float ySquish = 0.03f;

    private void Start()
    {
        CreateAsteroids();
    }

    private void Update()
    {
        //TODO: Using select will be slow, need to change if used for other than demo purposes
        Graphics.DrawMeshInstanced(mesh, 0, material, asteroids.Select(a => a.Matrix).ToList());

        foreach (Asteroid asteroid in asteroids) {
            if ((asteroid.position - Camera.main.transform.position).magnitude > radius) {
                ReplaceAsteroid(asteroid);
            }

            AnimateAsteroid(asteroid);
        }
    }

    private void AnimateAsteroid(Asteroid asteroid)
    {
        Vector3 heading = Vector3.Normalize(Vector3.Cross(transform.position - Camera.main.transform.position, transform.up));
        asteroid.position += (asteroid.velocity + heading / 2) * Time.deltaTime;
        asteroid.rotation = Quaternion.Euler(asteroid.angularVelocity * Time.time);
    }

    private void ReplaceAsteroid(Asteroid asteroid)
    {
        Vector3 randomInSquish = Random.onUnitSphere;
        randomInSquish.y *= ySquish;
        Vector3 cameraXZ = Camera.main.transform.position;
        cameraXZ.y = 0;
        asteroid.position = cameraXZ + randomInSquish * radius;
    }

    private void CreateAsteroids()
    {
        while (asteroids.Count < maximumAsteroids) {
            CreateNewAsteroid();
        }
    }

    private void CreateNewAsteroid()
    {
        Vector3 randomInSquish = Random.onUnitSphere;
        randomInSquish.y *= ySquish;
        Vector3 cameraXZ = Camera.main.transform.position;
        cameraXZ.y = 0;
        asteroids.Add(new Asteroid(cameraXZ + (randomInSquish * Random.Range(1, radius))));
    }
}
