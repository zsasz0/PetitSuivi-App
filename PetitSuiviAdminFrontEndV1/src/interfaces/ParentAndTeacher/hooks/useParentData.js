import { useState, useCallback, useEffect } from "react";
import { getParents } from "../api/apiService";

export const useParentData = () => {
    const [parents, setParents] = useState([]);
    const [loading, setLoading] = useState(true);

    const fetchParentData = useCallback(async () => {
        try {
            setLoading(true);
            const response = await getParents();
            const formatted = (response.data?.data || []).map((p) => ({
                id: p.cin, cin: p.cin, name: `${p.firstName || ""} ${p.lastName || ""}`.trim(),
                firstName: p.firstName || "", lastName: p.lastName || "",
                birthdate: p.birthdate || "-", phone: p.phone || "-", email: p.email || "-", adresse: p.adresse || "",
                children: p.children || [],
                childrenNames: (p.children || []).map(c => `${c.firstName} ${c.lastName}`.trim()).join(", ") || "-",
                childrenCount: (p.children || []).length,
                is_archived: !!p.is_archived, approval_status: (p.approval_status || "approved").toLowerCase(),
            }));
            setParents(formatted);
        } catch (error) {
            console.error("Failed to fetch parents", error);
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchParentData();
    }, [fetchParentData]);

    return { parents, setParents, loading, fetchParentData };
};
