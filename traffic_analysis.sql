SELECT
    INTKEY,
    COUNT(*) AS collision_count
FROM collisions
WHERE INTKEY IS NOT NULL
GROUP BY INTKEY
ORDER BY collision_count DESC;