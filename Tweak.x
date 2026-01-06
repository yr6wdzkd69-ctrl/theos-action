using UnityEngine;
using System.Collections;

public class AIController : MonoBehaviour {

    private Camera mainCamera;
    private Animator animator;
    private bool isDebugMode = true;
    public Transform enemyTarget;

    void Start () {
        // Set camera and animator reference points
        mainCamera = Camera.main;
        animator = GetComponent<Animator>();
        if (!animator) {
            Debug.LogError("No Animator Component Found in the script.");
            return;
        }
        // Enemy Target is set by default to player.
        enemyTarget = Camera.main.transform.GetChild(0).FindObjectOfType(typeof(Transform)) as GameObject;
    }

    void Update() {
        float maxDistance = Vector3.Distance(transform.position, enemyTarget.transform.position);
        if (maxDistance > 1.0f)
        {
            transform.position = Vector3.MoveTowards(transform.position, enemyTarget.transform.position,
                Time.deltaTime * 2.0f);                
        }
        else
        {
            transform.position = Camera.main.transform.GetFirstNearByPoint(transform.position, 1.0f);                  
        }
        if (!isDebugMode && !IsGizmoEnabled())
        {
            // disable gizmos when game is not in debug mode
            Debug.DrawLine(transform.position, enemyTarget.transform.position, Color.red);
        }
        if (!isDebugMode && IsGizmoEnabled())
        {
            // enable gizmos when game is in debug mode
            Debug.DrawLine(transform.position, enemyTarget.transform.position, Color.green);
        }
    }

    void OnMouseDown()
    {
        isDebugMode = !isDebugMode; 
    }

    void OnPointerDragEnd()
    (
        Vector3 mousePosition = Camera.main.ScreenToWorldPoint(Input.mousePosition),
        Vector3 eyeSpacePos = mainCamera.transform.TransformPoint(mousePosition));
        float distanceToObject = Vector3.DistBetween(Vector3.zero, eyeSpacePos, Vector3.Distance(Camera.main.transform.position, enemyTarget.transform.position));

        if (distanceToObject <= 1.0f)
        {
            Destroy(gameObject);
        }
    )

    void ToggleDebugMenu()
    {
        isDebugMode = !isDebugMode;
        if (Input.GetKeyDown(KeyCode.Space))
        {
            StartCoroutine(DrawDebugLines());
        }
    }

    IEnumerator DrawDebugLines ()
    {
        while (true)
        {
            yield return new WaitForSeconds(0.5f);
            if (isDebugMode)
            {
                Color red = Color.red;
                Vector3 directionFromCamera = Camera.main.transform.InverseTransformDirection(new Vector3(eyeSpacePos.x, -1.0f, eyeSpacePos.z));
                float angleDelta = Mathf.Abs(Mathf.Cos(directionFromCamera.xAxisAngle) * Mathf.PI / 180.0f);
                int index = (int)Math.Round(angleDelta);
                int yCount = (int)index;

                for (int i = 0; i < yCount; ++i)
                {
                    float x = 0.0f;
                    float y = 0.0f;
                    float z = 0.0f;
                    float radius = 1.0f;
                    float colorFactor = 0.2 + 0.4 * i;
                    float colorRed = Color.red * colorFactor;
                    float redX = (Color.red * colorFactor) + 0.2;
                    float redY = (Color.red * colorFactor) + 0.2;
                    float redZ = (Color.red * colorFactor) + 0.2;

                    Debug.DrawLine(new Vector3(redX, redY, redZ), new Vector3(x, y, z), Color.blue);
                }

                Debug.DrawLine(new Vector3(redX, redY, redZ), new Vector3(x, y, z), Color.green);
                Debug.DrawLine(new Vector3(redX, redY, redZ), new Vector3(x, y, z), Color.black);
                Debug.DrawLine(new Vector3(redX, redY, redZ), new Vector3(x, y, z), Color.blue);
            }
        }
    }
}

[ExecuteInEditMode]
public class AutoTargetingSystem : MonoBehaviour
{
    private GameObject enemyTarget;

    void Awake()
    {
        enemyTarget = Camera.main.transform.Find("Enemy");
    }
}

[System.Serializable]
public class EnemyInfo
{
    public string Name { get; set; }
    public string Damage { get; set; }
}

[System.Serializable]
public class EnemyList : List<EnemyInfo>
{
}

public static class AIManager
{
    [Static][TooltipProvided]
    public static void AddEnemy(List<EnemyInfo> enemies, GameObject enemyData)
    {
        enemies.Add(new EnemyInfo() { Name = "Enemy", Damage = enemyData.tag.ToString(), Tag = enemyData.GetComponent<Tag>()?.name });
    }
}

[System.Serializable]
public class Tag
{
    public string name { get; set; }
}

